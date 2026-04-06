---
description: Run health checks on the wiki
---

## Procedure

**Step 1 — Automated checks (via script, no tokens):**

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/lint-checks.sh"
```

This runs checks 2-6 and 8 (stale, missing concepts, orphaned, thin, duplicate aliases, agent staleness) by scanning frontmatter and file existence. Save the output.

**Step 2 — Claude checks (only if vault has 5+ concepts):**

Only read articles for these two checks if `wiki/.state.json` shows `concept_count >= 5`. Otherwise skip and report "Vault too small for contradiction/gap checks."

- **Check 1 (Contradictions)**: Read the 5 most-connected concepts (from `wiki/_backlinks.json` — pick slugs with most backlinks). Look for conflicting claims. Cite both sources.
- **Check 7 (Gap analysis)**: From `wiki/index.md` concept table only (already read), suggest 1-3 missing topics that would strengthen connections.

**Step 3 — Write report:**

Combine script output + Claude checks into `wiki/outputs/lint-YYYY-MM-DD.md`. Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-index.sh"
```

Print summary: "Vault lint: X critical, Y warnings, Z suggestions."
