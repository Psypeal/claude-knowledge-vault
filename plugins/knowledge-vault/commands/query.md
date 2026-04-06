---
description: Answer a question grounded in vault knowledge
argument-hint: <question>
---

## Procedure

The question is provided in `$ARGUMENTS`.

0. Read `.vault/preferences.md`. If `.vault/agent.md` exists AND (`vault_stats.total_queries >= 3` OR `wiki/.state.json` stats.source_count >= 5), also read `.vault/agent.md`.
0.5. **Agent pre-routing** (only if agent.md was read): Scan Query Patterns for keyword matches against the question. If a pattern matches, note its articles as priority reads. Check Concept Clusters -- if the query touches a clustered concept, plan to read the full cluster. Agent.md is advisory only -- always still read index.md next.
1. **Read index**: Read `wiki/index.md` to understand vault contents.
2. **Identify relevant articles**: From index tables, pick relevant summaries and concepts.
3. **Read articles** (Tier 2). Only go to raw sources (Tier 3) if summaries lack detail.
4. **Answer**: Compose a grounded answer using `[[wikilinks]]` to reference source articles inline.
5. **Dedup check**: Scan `wiki/outputs/` for existing outputs covering the same question. If a prior output already answers this, reference it instead of filing a duplicate. Only file if substantially new.
6. **Classify and act**:

| Tier | Rule | Action |
|------|------|--------|
| **Synthesize** | ALL of: (a) 2+ raw sources, (b) relationship not in any concept's `related`, (c) grounded in evidence | File to `wiki/outputs/`, update concept articles |
| **Record** | ANY of: (a) 200+ words with structured analysis, (b) 3+ concept articles, (c) user says "file it" | File to `wiki/outputs/` only |
| **Skip** | ANY of: (a) single source, no new insight, (b) under 100 words, (c) factual lookup, (d) duplicate | Answer only |

**When filing** (Synthesize or Record), write to `wiki/outputs/<descriptive-slug>.md`:
```yaml
---
title: "Q: The question asked"
query: "original question"
created: "ISO timestamp"
classification: synthesize|record
sources_consulted: [slug1, slug2]
concepts_referenced: [concept-a, concept-b]
new_connections:                    # synthesize only
  - from: concept-a
    to: concept-b
    strength: strong|moderate|weak
    evidence: "one-line summary"
---
```

**Connection strength** (synthesize only):

| Strength | Criteria | Graph impact |
|----------|----------|-------------|
| strong | 2+ independent sources, direct evidence | Add to `related` in both concepts |
| moderate | 1 source clear evidence, or 2+ indirect | Add to `related` with "(moderate)" note |
| weak | Inferred, not directly stated | Output only, flag for confirmation |

7. **Synthesize only**: Update affected concept articles -- add `related` entries (strong/moderate only, max 8 per concept; replace weakest if full), add Source Evidence note referencing output.
8. Update `wiki/index.md` recent outputs if filed.
9. Tell user which tier and why.

**Post-query agent.md update**: Read `${CLAUDE_PLUGIN_ROOT}/skills/vault-operations/references/agent-update-rules.md` for the full update procedure (steps a-i).
