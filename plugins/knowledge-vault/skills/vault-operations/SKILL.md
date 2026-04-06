---
name: knowledge-vault
description: Operate a local knowledge-base vault (.vault/ directory) within any project. This skill should be used when the user says "vault init", "vault ingest", "vault compile", "vault lint", "vault query", "vault process", "vault cleanup", "vault collect", "vault setup-sources", "vault status", "vault agent reset", "add to vault", "ask the vault", "check the vault", or references the .vault/ directory. The vault ingests raw sources, compiles them into a wiki of summaries and concept articles with cross-references, lints for consistency, and supports grounded Q&A.
user-invocable: false
---

# Knowledge Vault

A local, project-scoped knowledge base operated entirely by Claude. Raw sources are ingested, compiled into a wiki of summaries and concept articles, and queried on demand. The user browses in Obsidian but never edits wiki content directly.

## Commands

Each command contains its complete procedure. Invoke via `/knowledge-vault:<command>`.

| Command | Description |
|---------|-------------|
| `/knowledge-vault:init` | Initialize a knowledge vault in the current project |
| `/knowledge-vault:ingest` | Add a raw source to the vault (URL, text, or filepath) |
| `/knowledge-vault:compile` | Compile pending sources into wiki articles |
| `/knowledge-vault:lint` | Run 8 health checks on the wiki |
| `/knowledge-vault:query` | Answer a question grounded in vault knowledge |
| `/knowledge-vault:process` | Batch ingest Clippings and compile all pending |
| `/knowledge-vault:status` | Show vault state summary |
| `/knowledge-vault:cleanup` | Audit and actively fix wiki article quality |
| `/knowledge-vault:agent-reset` | Reset learned retrieval intelligence |
| `/knowledge-vault:collect` | Batch search academic databases and selectively ingest results |
| `/knowledge-vault:setup-sources` | Configure research MCP servers for academic collection |

## Directory Structure

```
.vault/
  preferences.md      User preferences (interview-generated, manually editable)
  agent.md            Learned retrieval intelligence (auto-maintained)
  sources.json        Configured research MCP servers
  Clippings/          Obsidian Web Clipper landing zone (default folder)
  raw/                Ingested sources with YAML frontmatter
    .manifest.json    Source registry
  wiki/               LLM-compiled knowledge base
    index.md          Master routing index (ALWAYS read first)
    _backlinks.json   Reverse link index (which articles link to which)
    concepts/         One article per topic
    summaries/        One summary per raw source
    outputs/          Filed query results and lint reports
    .state.json       Compilation and lint state
  templates/          Frontmatter skeletons for common types
```

## File Schemas

### Raw Source (`raw/<slug>.md`)

Slug: lowercase, hyphens for spaces, max 60 characters. Derived from the title.

```yaml
---
title: "Human-Readable Title"
source: "URL or origin identifier"
type: paper|article|repo|dataset|meeting|notes|clip
ingested: "ISO 8601 UTC timestamp"
tags: [tag1, tag2]
compiled: false
---

Content body here.
```

### Manifest (`raw/.manifest.json`)

```json
{
  "version": 1,
  "sources": [
    {
      "slug": "the-slug",
      "title": "The Title",
      "file": "the-slug.md",
      "type": "paper",
      "ingested": "2026-04-03T14:22:00Z",
      "compiled": false,
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

### Wiki State (`wiki/.state.json`)

```json
{
  "version": 1,
  "last_compiled": "ISO timestamp or null",
  "last_lint": "ISO timestamp or null",
  "stats": {
    "source_count": 0,
    "compiled_count": 0,
    "pending_count": 0,
    "concept_count": 0,
    "summary_count": 0,
    "output_count": 0
  }
}
```

### Summary Article (`wiki/summaries/<slug>.md`)

```yaml
---
title: "Summary: Original Title"
source_file: "raw/the-slug.md"
source_type: paper
compiled: "ISO timestamp"
concepts_extracted: [concept-a, concept-b]
word_count: 350
---

200-500 word summary. Include:
- Key findings or contributions
- Methods (if applicable)
- Relevance to this project
```

### Concept Article (`wiki/concepts/<slug>.md`)

```yaml
---
title: "Concept Name"
aliases: [alternative-name, abbreviation]
created: "ISO timestamp"
updated: "ISO timestamp"
sources: [source-slug-1, source-slug-2]
related: [other-concept-slug]
---

200-500 word synthesis of what the vault knows about this concept.

## Key Points
- ...

## Source Evidence
- From [[source-slug-1]]: "relevant quote or finding"
- From [[source-slug-2]]: "relevant quote or finding"

## Related Concepts
- [[Other Concept]] — brief explanation of the relationship
```

### Backlinks Index (`wiki/_backlinks.json`)

Maps each article to every article that links to it. Rebuilt during compile and cleanup.

```json
{
  "self-attention": ["transformer-architecture", "multi-head-attention"],
  "transformer-architecture": ["self-attention", "bert-overview"]
}
```

### Wiki Index (`wiki/index.md`)

```yaml
---
title: Vault Index
updated: "ISO timestamp"
---
```

Contains four tables: Source Summaries, Pending Compilation, Concepts, Recent Outputs.

### Agent File (`.vault/agent.md`)

Auto-maintained by Claude. Hard ceiling: 6,000 characters (~1,000 tokens). Only read when `total_queries >= 3` OR `source_count >= 5`.

Four bounded sections: Concept Clusters (8 max), Query Patterns (10 max), Source Signals (15 max), Corrections (5 FIFO).
