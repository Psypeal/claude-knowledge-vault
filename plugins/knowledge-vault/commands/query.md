---
description: Answer a question grounded in vault knowledge
argument-hint: <question>
---

Question: `$ARGUMENTS`

## Procedure

1. Read `wiki/index.md`.
2. Pick 2-4 relevant summaries or concepts from the index.
3. Read only those files. Go to `raw/` only if summaries lack detail.
4. Answer concisely with `[[wikilinks]]` to sources.

**That's it for most queries.** Do NOT read preferences.md, agent.md, agent-update-rules.md, or scan outputs/ unless specifically needed below.

## When to do more

**File the answer** (write to `wiki/outputs/`) ONLY when the user explicitly says "file it" or "save this". Then:
- Write `wiki/outputs/<slug>.md` with query frontmatter
- Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-index.sh"` to update index

**Update agent.md** ONLY when the user runs 3+ queries in the same session. Then read `${CLAUDE_PLUGIN_ROOT}/skills/vault-operations/references/agent-update-rules.md` and apply the update.

**Use agent pre-routing** ONLY if `.vault/agent.md` has `total_queries >= 5`. Read it before the index to prioritize articles.
