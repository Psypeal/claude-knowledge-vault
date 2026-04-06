---
description: Batch ingest Clippings and compile all pending
---

## Procedure

0. Read `.vault/preferences.md` -- apply preferences to ingestion and compilation.
1. Scan `.vault/Clippings/` for `.md` files.
2. For each file:
   a. Read it. Extract title and metadata from YAML frontmatter (Obsidian Web Clipper format).
   b. Generate slug from the title (lowercase, hyphens, max 60 chars).
   c. Move to `raw/<slug>.md` (reformat frontmatter to vault schema if needed).
   d. Add entry to `raw/.manifest.json`.
3. After all clippings ingested, run the compile procedure (from `/knowledge-vault:compile`) on all pending sources.
4. Report: "Processed N clippings, compiled M sources, extracted K new concepts."
