---
description: Batch search academic databases and selectively ingest results
argument-hint: "<search-query> [--count N] [--since YYYY]"
---

## Procedure

The search query and optional filters are in `$ARGUMENTS`. Parse: query text, `--count N` (default 10), `--since YYYY` (year filter).

1. Read `.vault/sources.json` for configured research servers.
2. For each enabled server, run the appropriate MCP search tool with the query and filters.
3. Deduplicate results across servers (match on title similarity and DOI).
4. Present a numbered results table to the user:

   | # | Title | Source | Year | Server |
   |---|-------|--------|------|--------|

5. User picks which results to ingest (e.g., "1,3,5" or "all").
6. For each selected result, run the ingest procedure (from `/knowledge-vault:ingest`) with `type: paper`.
7. After batch ingest, offer: "Run compile on the new sources now?"
