---
description: Add a raw source to the vault
argument-hint: <url|text|filepath>
---

## Procedure

The source is provided in `$ARGUMENTS`. Accept: URL, file path, pasted text, or MCP tool output.

1. **Determine source type**:
   - URL -> fetch with WebFetch, set `type: clip` or `type: article`
   - PubMed/Scholar MCP result -> set `type: paper`
   - Pasted text -> set `type: notes`
   - File path -> read the file, infer type from context

2. **Condense content** (token-efficiency step):

   **If the fetched content is 1000+ words AND the source is a URL, MCP result, or long pasted text** — produce a structured extraction instead of storing the full text:

   ```markdown
   ## Metadata
   - Authors: ...
   - Journal/Source: ...
   - Year: ...
   - DOI: ...

   ## Abstract
   [Original abstract if available, 200-300 words]

   ## Key Findings
   [Claude-extracted, 200-400 words structured as bullet points]

   ## Methods
   [Brief methodology summary, 100-200 words]

   ## Quantitative Data
   [Extracted key statistics: HRs, CIs, p-values, sample sizes, effect sizes]
   ```

   This caps raw files at ~800-1200 words regardless of source length. The original source URL is preserved in the `source:` field for re-fetching if full text is ever needed.

   **Skip condensation** (store full content as-is) when:
   - The content is short (<1000 words)
   - The source is meeting notes (`type: notes` and contextually brief)
   - The user explicitly says "store full text"

3. **Generate slug** from the title: lowercase, hyphens for spaces, max 60 chars.

4. **Run**: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/ingest.sh" "<slug>" "<title>" "<type>" [tags...]`

5. **Fill content**: Write the content body (condensed or full per step 2) into `raw/<slug>.md` using Edit tool. If a matching template exists in `.vault/templates/`, use its structure.

6. **Set source field**: If the source is a URL, set the `source:` field in the frontmatter.

7. **Update index** (via script — no need to read index.md):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/index-append.sh" "<slug>" "<type>"
   ```

**Context note**: Report only: "Ingested <title> as raw/<slug>.md". Do not echo file contents.
