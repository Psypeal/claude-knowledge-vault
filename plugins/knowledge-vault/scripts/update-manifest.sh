#!/bin/bash
# knowledge-vault: Update a manifest entry's fields.
# Usage: bash update-manifest.sh <slug> <key=value> [key=value...]
# Example: bash update-manifest.sh my-paper compiled=true

set -euo pipefail

VAULT_DIR="${VAULT_DIR:-.vault}"
SLUG="${1:?Usage: update-manifest.sh <slug> <key=value> [key=value...]}"
shift

MANIFEST="$VAULT_DIR/raw/.manifest.json"

if [ ! -f "$MANIFEST" ]; then
    echo "Error: $MANIFEST not found"
    exit 1
fi

python3 - "$SLUG" "$@" << 'PYEOF'
import json, sys

slug = sys.argv[1]
updates = {}
for arg in sys.argv[2:]:
    key, _, val = arg.partition('=')
    if val.lower() == 'true':
        updates[key] = True
    elif val.lower() == 'false':
        updates[key] = False
    else:
        try:
            updates[key] = int(val)
        except ValueError:
            updates[key] = val

import os
manifest_path = os.path.join(os.environ.get("VAULT_DIR", ".vault"), "raw", ".manifest.json")

with open(manifest_path, 'r') as f:
    manifest = json.load(f)

found = False
for source in manifest.get('sources', []):
    if source.get('slug') == slug:
        source.update(updates)
        found = True
        break

if not found:
    print(f"Warning: slug '{slug}' not found in manifest")
    sys.exit(1)

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f"Updated {slug}: {list(updates.keys())}")
PYEOF
