---
description: Compile pending sources into wiki articles
argument-hint: "[source-slug]"
---

## Procedure

If `$ARGUMENTS` names a specific source slug, compile only that source. Otherwise compile all pending.

0. Read `.vault/preferences.md` -- apply domain, priority, granularity, and compilation focus to all steps.
1. Read `raw/.manifest.json`. Identify entries where `compiled: false`.
2. For each uncompiled source:
   a. Read the raw file in full.
   b. **Create summary** at `wiki/summaries/<slug>.md`:
      ```yaml
      ---
      title: "Summary: Original Title"
      source_file: "raw/the-slug.md"
      source_type: paper
      compiled: "ISO timestamp"
      concepts_extracted: [concept-a, concept-b]
      word_count: 350
      ---
      ```
      200-500 words. Include key findings, methods, relevance.
   c. **Extract concepts**: Identify 2-6 key concepts.
   d. **For each concept**:
      - Exists: update -- add source evidence, update `sources` list, update `updated` timestamp, expand if new info warrants.
      - New: create `wiki/concepts/<concept-slug>.md` with 200-500 word article:
        ```yaml
        ---
        title: "Concept Name"
        aliases: [alt-name]
        created: "ISO timestamp"
        updated: "ISO timestamp"
        sources: [source-slug]
        related: [other-concept]
        ---
        ```
   e. **Cross-reference**: Update `related` fields in affected concepts. Use `[[wikilinks]]` in bodies.
   f. **Mark compiled**: Set `compiled: true` in raw file YAML and manifest entry.
3. **Rebuild index + backlinks**: Regenerate `wiki/index.md` (sources by date desc, concepts alphabetical). Rebuild `wiki/_backlinks.json` by scanning all `[[wikilinks]]`.
4. **Update state**: Update `wiki/.state.json` with new counts and `last_compiled`.
5. **Update agent.md**: For each compiled source, add/update Source Signals entry in `.vault/agent.md` (cited: 0, topic domains from extracted concepts). Increment `vault_stats.total_compiles`.

**Concept slugs**: lowercase, hyphens, max 60 chars (e.g., "Self-Attention" -> `self-attention`).

**Writing quality**: Read `${CLAUDE_PLUGIN_ROOT}/skills/vault-operations/references/writing-rules.md` for tone, length targets, anti-cramming/anti-thinning rules, and quality checkpoints.
