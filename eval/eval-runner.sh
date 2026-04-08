#!/bin/bash
# Autoresearch eval runner for knowledge-vault plugin.
# Runs test prompts via `claude -p`, captures output, scores against binary criteria.
# Usage: bash eval-runner.sh [--baseline] [--test TEST_ID]
#
# Requires: claude CLI, python3, jq
# Results written to eval/results/

set -euo pipefail

EVAL_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$EVAL_DIR/.." && pwd)"
RESULTS_DIR="$EVAL_DIR/results"
FIXTURE_DIR="$EVAL_DIR/fixtures"
TEST_DIR="$EVAL_DIR/tests"
WORK_DIR="/tmp/vault-eval-$$"

BASELINE=false
SINGLE_TEST=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --baseline) BASELINE=true; shift ;;
        --test) SINGLE_TEST="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

mkdir -p "$RESULTS_DIR" "$WORK_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
RUN_ID=$(date +%s)

if $BASELINE; then
    RESULTS_FILE="$RESULTS_DIR/baseline.tsv"
else
    RESULTS_FILE="$RESULTS_DIR/run-$RUN_ID.tsv"
fi

# Header
echo -e "run_id\ttimestamp\ttest_id\tcriterion\tpass\tevidence" > "$RESULTS_FILE"

run_test() {
    local TEST_ID="$1"
    local PROMPT_FILE="$TEST_DIR/$TEST_ID.txt"

    if [ ! -f "$PROMPT_FILE" ]; then
        echo "SKIP: $TEST_ID (no prompt file)"
        return
    fi

    echo "=== Running $TEST_ID ==="

    # Fresh vault for each test
    local TEST_VAULT="$WORK_DIR/$TEST_ID"
    mkdir -p "$TEST_VAULT"
    bash "$FIXTURE_DIR/setup-vault.sh" "$TEST_VAULT" 2>/dev/null

    # For compile-empty: mark all sources as compiled
    if [ "$TEST_ID" = "compile-empty" ]; then
        python3 -c "
import json
mf = '$TEST_VAULT/.vault/raw/.manifest.json'
with open(mf) as f: m = json.load(f)
for s in m['sources']: s['compiled'] = True
with open(mf, 'w') as f: json.dump(m, f, indent=2)
"
    fi

    # Read the prompt
    local PROMPT
    PROMPT=$(cat "$PROMPT_FILE")

    # Run via claude -p with stream-json to capture tool calls
    local OUTPUT_FILE="$WORK_DIR/$TEST_ID-output.jsonl"
    cd "$TEST_VAULT"
    claude -p --output-format stream-json --verbose \
        --dangerously-skip-permissions \
        --plugin-dir "$PLUGIN_DIR" \
        "$PROMPT" > "$OUTPUT_FILE" 2>/dev/null || true
    cd - > /dev/null

    # Score the output
    python3 "$EVAL_DIR/scorers/score-toolcalls.py" \
        --test "$TEST_ID" \
        --output "$OUTPUT_FILE" \
        --vault "$TEST_VAULT/.vault" \
        --run-id "$RUN_ID" \
        --timestamp "$TIMESTAMP" \
        >> "$RESULTS_FILE"

    echo "  Scored $TEST_ID"
}

# Test list
ALL_TESTS=(
    "ingest-url"
    "ingest-notes"
    "ingest-long"
    "ingest-special"
    "compile-single"
    "compile-batch"
    "compile-empty"
    "query-simple"
    "query-cross"
    "query-missing"
)

if [ -n "$SINGLE_TEST" ]; then
    run_test "$SINGLE_TEST"
else
    for t in "${ALL_TESTS[@]}"; do
        run_test "$t"
    done
fi

# Summary
echo ""
echo "=== Results ==="
TOTAL=$(grep -c "^$RUN_ID" "$RESULTS_FILE" || echo 0)
PASSED=$(grep -c "	1	" "$RESULTS_FILE" || echo 0)
echo "Total checks: $TOTAL"
echo "Passed: $PASSED"
echo "Pass rate: $(python3 -c "print(f'{$PASSED/$TOTAL*100:.0f}%' if $TOTAL > 0 else 'N/A')")"
echo "Results: $RESULTS_FILE"

# Cleanup
rm -rf "$WORK_DIR"
