#!/bin/bash
# knowledge-vault: Print vault status summary.
# Usage: bash vault-status.sh [vault-dir]

VAULT_DIR="${1:-.vault}"

if [ ! -d "$VAULT_DIR" ]; then
    echo "No vault found at $VAULT_DIR"
    exit 1
fi

MANIFEST="$VAULT_DIR/raw/.manifest.json"
STATE="$VAULT_DIR/wiki/.state.json"

echo "=== Knowledge Vault Status ==="
echo ""

# Source counts from manifest
if [ -f "$MANIFEST" ]; then
    python3 -c "
import json

with open('$MANIFEST', 'r') as f:
    m = json.load(f)

sources = m.get('sources', [])
total = len(sources)
compiled = sum(1 for s in sources if s.get('compiled'))
pending = total - compiled

print(f'Sources:    {total} total, {compiled} compiled, {pending} pending')

if pending > 0:
    print(f'  Pending:')
    for s in sources:
        if not s.get('compiled'):
            print(f'    - {s[\"slug\"]} ({s[\"type\"]})')
"
else
    echo "Sources:    no manifest found"
fi

echo ""

# Wiki stats from state
if [ -f "$STATE" ]; then
    python3 -c "
import json

with open('$STATE', 'r') as f:
    s = json.load(f)

stats = s.get('stats', {})
print(f'Concepts:   {stats.get(\"concept_count\", 0)}')
print(f'Summaries:  {stats.get(\"summary_count\", 0)}')
print(f'Outputs:    {stats.get(\"output_count\", 0)}')
print(f'')
print(f'Last compiled: {s.get(\"last_compiled\", \"never\")}')
print(f'Last lint:     {s.get(\"last_lint\", \"never\")}')
"
else
    echo "Wiki state: no state file found"
fi

echo ""

# Inbox count
CLIPPINGS_COUNT=$(find "$VAULT_DIR/Clippings" -name "*.md" 2>/dev/null | wc -l)
echo "Clippings:  $CLIPPINGS_COUNT items waiting"

echo ""

# Agent stats
AGENT_FILE="$VAULT_DIR/agent.md"
if [ -f "$AGENT_FILE" ]; then
    python3 -c "
import re

with open('$AGENT_FILE', 'r') as f:
    content = f.read()

# Extract YAML frontmatter
fm_match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
if not fm_match:
    print('Agent:      no frontmatter found')
    exit()

fm = fm_match.group(1)

def get_val(key):
    m = re.search(rf'{key}:\s*(\d+)', fm)
    return int(m.group(1)) if m else 0

total_queries = get_val('total_queries')
cache_hits = get_val('cache_hits')
tier3_fallbacks = get_val('tier3_fallbacks')

if total_queries == 0:
    print('Agent:      inactive (no queries yet)')
else:
    hit_rate = round(cache_hits / total_queries * 100)
    print(f'Agent:      active ({total_queries} queries, {hit_rate}% cache hit rate)')

    # Count entries in each section
    def count_entries(section_name):
        pat = rf'## {section_name}\n(.*?)(?=\n## |\Z)'
        m = re.search(pat, content, re.DOTALL)
        if not m:
            return 0
        body = m.group(1).strip()
        if body.startswith('_') and body.endswith('_'):
            return 0
        return len([l for l in body.split('\n') if l.strip() and not l.strip().startswith('#')])

    clusters = count_entries('Concept Clusters')
    patterns = count_entries('Query Patterns')
    signals = count_entries('Source Signals')

    print(f'  Clusters: {clusters}/8')
    print(f'  Patterns: {patterns}/10')
    print(f'  Signals:  {signals}/15')
"
else
    echo "Agent:      not initialized"
fi

echo ""
echo "==========================="
