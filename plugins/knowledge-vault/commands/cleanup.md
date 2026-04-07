---
description: Audit and actively fix wiki article quality
---

## Procedure

0. Read `.vault/preferences.md` only if not already read in this session.
1. **Context building**: Read `wiki/index.md`, `wiki/_backlinks.json`, and scan all concept and summary articles. Map the full wiki structure.
2. **Per-article audit** -- for each concept article, evaluate:

| Check | Bad sign | Action |
|:------|:---------|:-------|
| Structure | Facts appended chronologically, not by theme | Restructure around themes |
| Length | Over 80 lines | Split into sub-concept articles |
| Length | Under 15 lines (stub) | Enrich from raw sources or flag |
| Tone | Peacock words, editorial voice, rhetorical questions | Rewrite to factual, Wikipedia-flat tone |
| Quotes | More than 2 direct quotes | Keep 2 most impactful, paraphrase rest |
| Wikilinks | Missing connections to related concepts | Add `[[wikilinks]]` and update `related` |
| Coherence | "Here are 4 sources that mention X" | Rewrite to "X matters because Y, supported by..." |

3. **Split overstuffed**: If 3+ distinct sub-topics in separate paragraphs, create dedicated concept articles. Update cross-references.
4. **Enrich stubs**: For articles under 15 lines, re-read raw sources in `sources` frontmatter. Extract detail to reach 15+ lines.
5. **Fix broken wikilinks**: `[[links]]` to non-existent articles -- create the missing article or remove the link.
6. **Rebuild** (via script — no need to re-read every file):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-index.sh"
   ```
7. Report: "Cleanup complete: X articles restructured, Y stubs enriched, Z articles split, W broken links fixed."

**Writing quality**: Only read `${CLAUDE_PLUGIN_ROOT}/skills/vault-operations/references/writing-rules.md` if not already read in this session.

**Context note**: Report only summary counts. Do not echo full article contents back to the user.
