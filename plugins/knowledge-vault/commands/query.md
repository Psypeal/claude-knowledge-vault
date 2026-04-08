---
description: Answer a question grounded in vault knowledge
argument-hint: <question>
---

Question: `$ARGUMENTS`

## Procedure

1. Read `wiki/index.md`.
2. Pick 2-4 relevant summaries or concepts from the index.
3. Read only those files. Read at most 1 raw file, and only if the summary lacks the needed detail.
4. Answer concisely with `[[wikilinks]]` to sources.

Do NOT read any of these files: `preferences.md`, `agent.md`, `agent-update-rules.md`, `writing-rules.md`, `_backlinks.json`, `.manifest.json`, `.state.json`, `sources.json`. The only files you should read are `wiki/index.md` and the 2-4 articles selected from the index.

## When to do more

**File the answer** ONLY when the user says "file it" or "save this". Then write to `wiki/outputs/` and run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-index.sh"`.

**Update agent.md** ONLY after 3+ queries in the same session. Then read `${CLAUDE_PLUGIN_ROOT}/skills/vault-operations/references/agent-update-rules.md`.

**Agent pre-routing** ONLY if `total_queries >= 5` in agent.md. Read it before index.
