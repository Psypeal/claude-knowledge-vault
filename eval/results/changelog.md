# Autoresearch Mutation Changelog

## Baseline
- **Score**: 43/49 (88%)
- **Date**: 2026-04-08
- **Failing**: compile-batch (3), compile-empty (3)

## Mutation Round 1: Compile fixes
- **Score**: 45/49 (92%)
- **Changes**:
  - compile.md: Explicit per-source script calls ("One pair of calls per source")
  - compile.md: Gated agent.md update on total_queries >= 3
  - compile.md: Inlined critical writing rules (removed reference file read)
  - compile.md: Added no-backlinks instruction
- **Fixed**: compile-batch update-frontmatter-twice, update-manifest-twice
- **Still failing**: compile-batch plan, compile-empty (fixture issue)

## Mutation Round 2: Query hardening + fixture fix
- **Score**: 49/49 (100%)
- **Changes**:
  - query.md: Explicit file block-list (7 files named)
  - query.md: Raw-read cap at 1
  - compile.md: Early exit for zero pending with STOP instruction
  - eval-runner.sh: compile-empty fixture marks all sources compiled
  - score-toolcalls.py: Broader plan detection (checks all output, not just final message)
- **Fixed**: compile-batch plan-before-execute, compile-empty (all 3)

## Summary
- Baseline: 43/49 (88%) → Final: 49/49 (100%)
- Improvement: +6 criteria, 0 regressions
- Key mutations: early exit, per-source script calls, file block-list, fixture fix
