---
description: Batch ingest papers from a Zotero collection via zotero-mcp
argument-hint: "<collection-name-or-keyword>"
---

## Procedure

The collection name or keyword is in `$ARGUMENTS`. Requires the `zotero-mcp` server (install: `uv tool install zotero-mcp-server && zotero-mcp setup`).

1. **Verify zotero-mcp is available**: If `mcp__zotero__*` tools are not present in this session, stop and tell the user: "Zotero MCP not found. Install with: `uv tool install zotero-mcp-server && zotero-mcp setup`, then restart Claude Code."

2. **Find the collection**: Call `mcp__zotero__zotero_get_collections` with the keyword.
   - If zero matches: report and stop.
   - If multiple matches: list them and ask user to pick one.
   - If one match: proceed.

3. **List items**: Call `mcp__zotero__zotero_get_collection_items` for the chosen collection.
   - If empty: report "Collection is empty" and stop.

4. **Present selection table**:

   | # | Title | Authors | Year | Type |
   |---|-------|---------|------|------|

   Ask: "Ingest which? (e.g., `1,3,5` or `all`)"

5. **For each selected item**, run this per-item sub-procedure:

   a. **Fetch metadata**: `mcp__zotero__zotero_get_item_metadata` with `include_abstract: true`.
   b. **Fetch full text** (if item has a PDF attachment): `mcp__zotero__zotero_get_item_fulltext`. If unavailable, that's fine — many Zotero items are reference-only, and the abstract alone carries real signal for compile. Record `has_fulltext = false` and proceed.
   c. **Fetch annotations** (if user has highlighted the PDF): `mcp__zotero__zotero_get_annotations`. Include them in the Key Findings section when present. Skip silently if none.

   d. **Generate slug** from the title: lowercase, hyphens for spaces, max 60 chars, strip punctuation.

   e. **Extract fields** from the metadata response:
      - `zotero_key` — the item's Zotero key
      - `citekey` — BetterBibTeX citation key if present (else empty string)
      - `doi` — DOI if present (else empty string)
      - `year` — publication year as integer (else empty string)
      - `authors_csv` — **pipe-separated** list of author names (use `|` as separator, not comma — authors often have commas in their names)
      - `tags` — Zotero item tags (filter to alphanumeric + hyphens)

   f. **Create the raw file skeleton**:
      ```bash
      bash "${CLAUDE_PLUGIN_ROOT}/scripts/ingest-zotero.sh" "<slug>" "<title>" "<zotero_key>" "<citekey>" "<doi>" "<year>" "<authors_csv>" [tags...]
      ```

   g. **Condense content** into the raw file body using Edit tool. Apply the same structured extraction as `/knowledge-vault:ingest` (cap at ~800-1200 words):
      ```markdown
      ## Metadata
      - Authors: ...
      - Journal/Source: ...
      - Year: ...
      - DOI: ...
      - Zotero key: ...

      ## Abstract
      [From metadata, 200-300 words verbatim]

      ## Key Findings
      [200-400 words, bullet points]

      ## Methods
      [Brief methodology, 100-200 words]

      ## Quantitative Data
      [HRs, CIs, p-values, sample sizes, effect sizes]
      ```

      **How to fill Key Findings / Methods / Quantitative Data:**
      - **If `has_fulltext = true`**: synthesize from the fulltext + annotations.
      - **If `has_fulltext = false`** (reference-only item): synthesize from the abstract itself. Abstracts of peer-reviewed papers typically contain the headline findings, primary methods, and key statistics — extract them into the corresponding sections. Do NOT write "full text not available" as a stub; use the abstract as the source and note "(from abstract)" beside any section that would benefit from fulltext context.
      - **If the abstract is also missing or under 100 words**: write a one-line note "Minimal metadata only — re-fetch from Zotero if deeper analysis is needed" and omit the synthesis sections.

      Do NOT dump raw fulltext. The full paper stays in Zotero — the raw file is the structured extraction.

   h. **Update index**:
      ```bash
      bash "${CLAUDE_PLUGIN_ROOT}/scripts/index-append.sh" "<slug>" "paper"
      ```

6. **Final report**: "Ingested N papers from collection `<name>`. Run `/knowledge-vault:compile` now to build summaries and concepts?"

## Notes

- **Source of truth**: Zotero owns the PDF, metadata, and annotations. The vault's raw file is a condensed extraction — re-fetchable via the `zotero_key` in frontmatter.
- **Duplicates**: If a slug already exists in `raw/`, `ingest-zotero.sh` reports "Skipped" and continues. Re-running the command is safe.
- **Webpage items**: Zotero `webpage` items are valid — they still have title, URL, and sometimes fulltext. Treat them the same way.
- **Context note**: Report only the per-item line "Ingested <title>" and the final count. Do not echo file contents or frontmatter.
