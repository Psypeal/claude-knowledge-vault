---
description: Run 8 health checks on the wiki
---

## Procedure

0. Read `.vault/preferences.md` -- preferences inform what counts as "thin", "stale", or a priority gap.
1. Read `wiki/index.md` and scan all concept and summary articles.
2. Run these checks:

| # | Check | Look for | Severity |
|---|-------|----------|----------|
| 1 | Contradictions | Conflicting claims across articles; cite both sources | Critical |
| 2 | Stale articles | Concept `updated` older than newest source in its `sources` list | Warning |
| 3 | Missing concepts | `[[wikilink]]` targets with no concept article | Warning |
| 4 | Orphaned articles | Concepts with zero sources, or summaries whose raw file is missing | Warning |
| 5 | Thin articles | Concept articles under 100 words | Suggestion |
| 6 | Duplicate concepts | Same topic covered twice (check `aliases` overlap + title similarity) | Warning |
| 7 | Gap analysis | Suggest missing topics that would strengthen the knowledge graph | Suggestion |
| 8 | Agent staleness | agent.md references non-existent concepts, sources, or deleted articles | Warning |

3. Write report to `wiki/outputs/lint-YYYY-MM-DD.md` grouped by check.
4. Update `wiki/.state.json` with `last_lint` timestamp.
5. Print summary: "Vault lint: X critical, Y warnings, Z suggestions."
6. If check 8 finds issues, automatically clean agent.md by removing references to non-existent content.
