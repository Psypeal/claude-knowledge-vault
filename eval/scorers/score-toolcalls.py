#!/usr/bin/env python3
"""Score vault command outputs against binary eval criteria.

Reads stream-json output from `claude -p --output-format stream-json --verbose`
and checks tool call patterns and response text against per-test binary criteria.

Usage: python3 score-toolcalls.py --test TEST_ID --output OUTPUT_FILE --vault VAULT_DIR --run-id RUN_ID --timestamp TS
"""

import json, sys, re, argparse, os

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--test", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--vault", required=True)
    p.add_argument("--run-id", required=True)
    p.add_argument("--timestamp", required=True)
    return p.parse_args()

def load_stream_output(path):
    """Parse stream-json lines. Returns tool_calls list and final message text."""
    tool_calls = []
    message_parts = []
    result_text = ""

    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                except:
                    continue

                t = d.get("type", "")

                if t == "assistant":
                    msg = d.get("message", {})
                    for c in msg.get("content", []):
                        ct = c.get("type", "")
                        if ct == "tool_use":
                            tool_calls.append({
                                "name": c.get("name", ""),
                                "input": c.get("input", {})
                            })
                        elif ct == "text":
                            message_parts.append(c.get("text", ""))

                elif t == "result":
                    result_text = str(d.get("result", ""))

    except Exception as e:
        print(f"# Parse error: {e}", file=sys.stderr)

    # Use result text if available, else join message parts
    final = result_text if result_text else " ".join(message_parts)
    return tool_calls, final

def bash_call_count(tool_calls, pattern):
    count = 0
    for tc in tool_calls:
        if tc["name"] == "Bash":
            cmd = str(tc.get("input", {}).get("command", ""))
            if re.search(pattern, cmd, re.IGNORECASE):
                count += 1
    return count

def read_call_count(tool_calls, pattern):
    count = 0
    for tc in tool_calls:
        if tc["name"] == "Read":
            path = str(tc.get("input", {}).get("file_path", ""))
            if re.search(pattern, path, re.IGNORECASE):
                count += 1
    return count

def write_call_exists(tool_calls, pattern):
    for tc in tool_calls:
        if tc["name"] in ("Write", "Edit"):
            args_str = str(tc.get("input", {}))
            if re.search(pattern, args_str, re.IGNORECASE):
                return True
    return False

def word_count(text):
    return len(text.split())

def contains(text, pattern):
    return bool(re.search(pattern, text, re.IGNORECASE))

def emit(run_id, ts, test_id, criterion, passed, evidence):
    print(f"{run_id}\t{ts}\t{test_id}\t{criterion}\t{1 if passed else 0}\t{evidence}")

# --- Per-test eval criteria ---

def eval_ingest_url(tc, msg, vault, rid, ts):
    tid = "ingest-url"
    emit(rid, ts, tid, "ingest-sh-called", bash_call_count(tc, "ingest\\.sh") >= 1, f"calls={bash_call_count(tc, 'ingest\\.sh')}")
    emit(rid, ts, tid, "index-append-called", bash_call_count(tc, "index-append") >= 1, f"calls={bash_call_count(tc, 'index-append')}")
    emit(rid, ts, tid, "no-content-echo", not contains(msg, "## Key Findings|## Methods|## Abstract"), "checked message")
    emit(rid, ts, tid, "response-under-100w", word_count(msg) <= 100, f"words={word_count(msg)}")

def eval_ingest_notes(tc, msg, vault, rid, ts):
    tid = "ingest-notes"
    emit(rid, ts, tid, "ingest-sh-called", bash_call_count(tc, "ingest\\.sh") >= 1, f"calls={bash_call_count(tc, 'ingest\\.sh')}")
    emit(rid, ts, tid, "index-append-called", bash_call_count(tc, "index-append") >= 1, f"calls={bash_call_count(tc, 'index-append')}")
    emit(rid, ts, tid, "not-condensed", not write_call_exists(tc, "Key Findings"), "no condensation in write")
    emit(rid, ts, tid, "type-is-notes", bash_call_count(tc, "notes") >= 1, "checked ingest args")
    emit(rid, ts, tid, "response-under-100w", word_count(msg) <= 100, f"words={word_count(msg)}")

def eval_ingest_long(tc, msg, vault, rid, ts):
    tid = "ingest-long"
    emit(rid, ts, tid, "ingest-sh-called", bash_call_count(tc, "ingest\\.sh") >= 1, f"calls={bash_call_count(tc, 'ingest\\.sh')}")
    emit(rid, ts, tid, "no-content-echo", not contains(msg, "## Key Findings|## Methods"), "checked message")
    emit(rid, ts, tid, "response-under-100w", word_count(msg) <= 100, f"words={word_count(msg)}")

def eval_ingest_special(tc, msg, vault, rid, ts):
    tid = "ingest-special"
    # Check no SyntaxError in any bash output
    all_bash = " ".join(str(tc.get("input", {})) for tc in tc if tc.get("name") == "Bash")
    emit(rid, ts, tid, "ingest-sh-no-error", not contains(all_bash + msg, "SyntaxError|Error:"), "no error")
    emit(rid, ts, tid, "index-append-called", bash_call_count(tc, "index-append") >= 1, f"calls={bash_call_count(tc, 'index-append')}")
    emit(rid, ts, tid, "response-under-100w", word_count(msg) <= 100, f"words={word_count(msg)}")

def eval_compile_single(tc, msg, vault, rid, ts):
    tid = "compile-single"
    emit(rid, ts, tid, "prefs-read-max-once", read_call_count(tc, "preferences\\.md") <= 1, f"reads={read_call_count(tc, 'preferences\\.md')}")
    emit(rid, ts, tid, "update-frontmatter-called", bash_call_count(tc, "update-frontmatter") >= 1, f"calls={bash_call_count(tc, 'update-frontmatter')}")
    emit(rid, ts, tid, "update-manifest-called", bash_call_count(tc, "update-manifest") >= 1, f"calls={bash_call_count(tc, 'update-manifest')}")
    emit(rid, ts, tid, "rebuild-index-once", bash_call_count(tc, "rebuild-index") == 1, f"calls={bash_call_count(tc, 'rebuild-index')}")
    emit(rid, ts, tid, "update-state-called", bash_call_count(tc, "update-state") >= 1, f"calls={bash_call_count(tc, 'update-state')}")
    emit(rid, ts, tid, "response-under-150w", word_count(msg) <= 150, f"words={word_count(msg)}")

def eval_compile_batch(tc, msg, vault, rid, ts):
    tid = "compile-batch"
    emit(rid, ts, tid, "prefs-read-max-once", read_call_count(tc, "preferences\\.md") <= 1, f"reads={read_call_count(tc, 'preferences\\.md')}")
    emit(rid, ts, tid, "writing-rules-max-once", read_call_count(tc, "writing-rules") <= 1, f"reads={read_call_count(tc, 'writing-rules')}")
    emit(rid, ts, tid, "update-frontmatter-twice", bash_call_count(tc, "update-frontmatter") == 2, f"calls={bash_call_count(tc, 'update-frontmatter')}")
    emit(rid, ts, tid, "update-manifest-twice", bash_call_count(tc, "update-manifest") == 2, f"calls={bash_call_count(tc, 'update-manifest')}")
    emit(rid, ts, tid, "rebuild-index-once", bash_call_count(tc, "rebuild-index") == 1, f"calls={bash_call_count(tc, 'rebuild-index')}")
    # Check for plan in both message AND tool call text (plan may appear in intermediate output)
    all_text = msg + " " + " ".join(str(tc.get("input", {})) for tc in tc)
    emit(rid, ts, tid, "plan-before-execute", contains(all_text, "plan|concepts to|merged|batch|both sources"), "checked all output")
    emit(rid, ts, tid, "response-under-150w", word_count(msg) <= 150, f"words={word_count(msg)}")

def eval_compile_empty(tc, msg, vault, rid, ts):
    tid = "compile-empty"
    emit(rid, ts, tid, "no-raw-reads", read_call_count(tc, "raw/.*\\.md") == 0, f"raw_reads={read_call_count(tc, 'raw/.*\\.md')}")
    emit(rid, ts, tid, "no-rebuild", bash_call_count(tc, "rebuild-index") == 0, f"calls={bash_call_count(tc, 'rebuild-index')}")
    emit(rid, ts, tid, "mentions-nothing-pending", contains(msg, "nothing|no sources|0 pending|already compiled|no.*pending"), "checked message")
    emit(rid, ts, tid, "response-under-50w", word_count(msg) <= 50, f"words={word_count(msg)}")

def eval_query_simple(tc, msg, vault, rid, ts):
    tid = "query-simple"
    emit(rid, ts, tid, "index-read-first", read_call_count(tc, "index\\.md") >= 1, f"reads={read_call_count(tc, 'index\\.md')}")
    emit(rid, ts, tid, "max-4-articles", read_call_count(tc, "wiki/(concepts|summaries)/") <= 4, f"reads={read_call_count(tc, 'wiki/(concepts|summaries)/')}")
    emit(rid, ts, tid, "no-prefs-read", read_call_count(tc, "preferences\\.md") == 0, f"reads={read_call_count(tc, 'preferences\\.md')}")
    emit(rid, ts, tid, "no-agent-rules-read", read_call_count(tc, "agent-update-rules") == 0, f"reads={read_call_count(tc, 'agent-update-rules')}")
    emit(rid, ts, tid, "no-output-filed", not write_call_exists(tc, "wiki/outputs/"), "checked writes")
    emit(rid, ts, tid, "response-under-200w", word_count(msg) <= 200, f"words={word_count(msg)}")

def eval_query_cross(tc, msg, vault, rid, ts):
    tid = "query-cross"
    emit(rid, ts, tid, "index-read", read_call_count(tc, "index\\.md") >= 1, f"reads={read_call_count(tc, 'index\\.md')}")
    emit(rid, ts, tid, "max-4-articles", read_call_count(tc, "wiki/(concepts|summaries)/") <= 4, f"reads={read_call_count(tc, 'wiki/(concepts|summaries)/')}")
    emit(rid, ts, tid, "has-wikilink", contains(msg, r"\[\["), "checked for [[links]]")
    emit(rid, ts, tid, "no-prefs-read", read_call_count(tc, "preferences\\.md") == 0, f"reads={read_call_count(tc, 'preferences\\.md')}")
    emit(rid, ts, tid, "no-output-filed", not write_call_exists(tc, "wiki/outputs/"), "checked writes")
    emit(rid, ts, tid, "response-under-200w", word_count(msg) <= 200, f"words={word_count(msg)}")

def eval_query_missing(tc, msg, vault, rid, ts):
    tid = "query-missing"
    emit(rid, ts, tid, "index-read", read_call_count(tc, "index\\.md") >= 1, f"reads={read_call_count(tc, 'index\\.md')}")
    emit(rid, ts, tid, "max-1-extra-read", read_call_count(tc, "wiki/(concepts|summaries)/") <= 1, f"reads={read_call_count(tc, 'wiki/(concepts|summaries)/')}")
    emit(rid, ts, tid, "says-not-covered", contains(msg, "not.*(?:cover|found|vault|mention)|no.*(?:information|articles|sources|content)"), "checked message")
    emit(rid, ts, tid, "no-raw-reads", read_call_count(tc, "/raw/") == 0, f"reads={read_call_count(tc, '/raw/')}")
    emit(rid, ts, tid, "response-under-100w", word_count(msg) <= 100, f"words={word_count(msg)}")

EVAL_MAP = {
    "ingest-url": eval_ingest_url,
    "ingest-notes": eval_ingest_notes,
    "ingest-long": eval_ingest_long,
    "ingest-special": eval_ingest_special,
    "compile-single": eval_compile_single,
    "compile-batch": eval_compile_batch,
    "compile-empty": eval_compile_empty,
    "query-simple": eval_query_simple,
    "query-cross": eval_query_cross,
    "query-missing": eval_query_missing,
}

if __name__ == "__main__":
    args = parse_args()
    tool_calls, message = load_stream_output(args.output)

    if args.test in EVAL_MAP:
        EVAL_MAP[args.test](tool_calls, message, args.vault, args.run_id, args.timestamp)
    else:
        print(f"Unknown test: {args.test}", file=sys.stderr)
        sys.exit(1)
