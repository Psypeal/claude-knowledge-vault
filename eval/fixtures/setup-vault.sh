#!/bin/bash
# Create a deterministic test vault with known content for eval runs.
# Usage: bash setup-vault.sh <target-dir>
# Creates a .vault/ with 3 compiled sources, 2 pending, 5 concepts.

set -euo pipefail

TARGET="${1:?Usage: setup-vault.sh <target-dir>}"
VAULT="$TARGET/.vault"

# Clean slate
rm -rf "$VAULT"
mkdir -p "$VAULT"/{Clippings,raw,wiki/{concepts,summaries,outputs},templates}

# --- Manifest (3 compiled, 2 pending) ---
cat > "$VAULT/raw/.manifest.json" << 'EOF'
{
  "version": 1,
  "sources": [
    {"slug": "ambient-air-pollution-dementia-meta", "title": "Ambient air pollution and clinical dementia: systematic review and meta-analysis", "file": "ambient-air-pollution-dementia-meta.md", "type": "paper", "ingested": "2026-04-07T10:00:00Z", "compiled": true, "tags": ["air-pollution", "dementia", "meta-analysis"]},
    {"slug": "air-pollution-dementia-review", "title": "Air Pollution and Dementia: A Systematic Review", "file": "air-pollution-dementia-review.md", "type": "paper", "ingested": "2026-04-07T10:05:00Z", "compiled": true, "tags": ["air-pollution", "dementia", "systematic-review"]},
    {"slug": "lancet-dementia-prevention-2020", "title": "Dementia prevention, intervention, and care: 2020 report of the Lancet Commission", "file": "lancet-dementia-prevention-2020.md", "type": "paper", "ingested": "2026-04-07T10:10:00Z", "compiled": true, "tags": ["dementia", "prevention", "lancet"]},
    {"slug": "hypertension-stroke-mediators", "title": "Hypertension and Stroke as Mediators of Air Pollution Exposure and Incident Dementia", "file": "hypertension-stroke-mediators.md", "type": "paper", "ingested": "2026-04-07T10:15:00Z", "compiled": false, "tags": ["air-pollution", "hypertension", "stroke", "dementia"]},
    {"slug": "air-pollution-dementia-bmj", "title": "Air pollution and dementia", "file": "air-pollution-dementia-bmj.md", "type": "clip", "ingested": "2026-04-07T10:20:00Z", "compiled": false, "tags": ["air-pollution", "dementia"]}
  ]
}
EOF

# --- Raw sources (compiled ones have compiled: true) ---
cat > "$VAULT/raw/ambient-air-pollution-dementia-meta.md" << 'EOF'
---
title: "Ambient air pollution and clinical dementia: systematic review and meta-analysis"
source: "https://pubmed.ncbi.nlm.nih.gov/37019461/"
type: paper
ingested: "2026-04-07T10:00:00Z"
tags: [air-pollution, dementia, meta-analysis]
compiled: true
---

## Metadata
- Authors: Wilker et al.
- Journal: BMJ
- Year: 2023

## Key Findings
- PM2.5 associated with increased dementia risk (HR 1.17 per 2 μg/m³)
- NO2 showed consistent positive associations
- PM10 associations less consistent across studies
- 51 studies included, strongest evidence for PM2.5

## Methods
- Systematic review with meta-analysis, ROBINS-E risk of bias tool
- EMBASE, PubMed, Web of Science through July 2022
EOF

cat > "$VAULT/raw/air-pollution-dementia-review.md" << 'EOF'
---
title: "Air Pollution and Dementia: A Systematic Review"
source: "https://pubmed.ncbi.nlm.nih.gov/example1/"
type: paper
ingested: "2026-04-07T10:05:00Z"
tags: [air-pollution, dementia, systematic-review]
compiled: true
---

## Metadata
- Authors: Peters et al.
- Journal: Journal of Alzheimers Disease
- Year: 2019

## Key Findings
- Traffic-related air pollution linked to cognitive decline
- PM2.5 exposure associated with hippocampal volume reduction
- Dose-response relationship observed for long-term exposure
- Vulnerable populations: elderly, APOE4 carriers

## Methods
- Systematic review of 13 cohort studies
- Exposure assessment via monitoring stations and land-use models
EOF

cat > "$VAULT/raw/lancet-dementia-prevention-2020.md" << 'EOF'
---
title: "Dementia prevention, intervention, and care: 2020 report of the Lancet Commission"
source: "https://doi.org/10.1016/S0140-6736(20)30367-6"
type: paper
ingested: "2026-04-07T10:10:00Z"
tags: [dementia, prevention, lancet]
compiled: true
---

## Metadata
- Authors: Livingston et al.
- Journal: The Lancet
- Year: 2020

## Key Findings
- 12 modifiable risk factors account for ~40% of dementia cases
- Air pollution added as new risk factor (2% population attributable fraction)
- Other factors: education, hearing loss, TBI, hypertension, alcohol, obesity, smoking, depression, social isolation, physical inactivity, diabetes

## Methods
- Expert commission review with meta-analytic synthesis
- Population attributable fraction calculations
EOF

cat > "$VAULT/raw/hypertension-stroke-mediators.md" << 'EOF'
---
title: "Hypertension and Stroke as Mediators of Air Pollution Exposure and Incident Dementia"
source: "https://pubmed.ncbi.nlm.nih.gov/example2/"
type: paper
ingested: "2026-04-07T10:15:00Z"
tags: [air-pollution, hypertension, stroke, dementia]
compiled: false
---

## Metadata
- Authors: Kulick et al.
- Journal: Neurology
- Year: 2023

## Key Findings
- PM2.5 linked to dementia partially through hypertension and stroke pathways
- Mediation analysis: 12-18% of PM2.5-dementia effect mediated by hypertension
- Stroke mediates an additional 8-11% of the total effect
- Direct PM2.5 neurotoxicity accounts for remaining association

## Methods
- Prospective cohort (N=6,008), 15-year follow-up
- Causal mediation analysis with Cox proportional hazards
- Exposure: annual PM2.5 from EPA monitoring + satellite data

## Quantitative Data
- HR for dementia per 1 μg/m³ PM2.5: 1.08 (95% CI: 1.03-1.14)
- Mediation by hypertension: 15.2% (95% CI: 8.1-24.3%)
- Mediation by stroke: 9.7% (95% CI: 4.2-17.8%)
EOF

cat > "$VAULT/raw/air-pollution-dementia-bmj.md" << 'EOF'
---
title: "Air pollution and dementia"
source: "https://pubmed.ncbi.nlm.nih.gov/37019447/"
type: clip
ingested: "2026-04-07T10:20:00Z"
tags: [air-pollution, dementia]
compiled: false
---

Short BMJ editorial summarizing evidence that air pollution is a modifiable risk factor for dementia. Notes that PM2.5 has the strongest evidence base. Calls for policy action to reduce ambient air pollution levels.
EOF

# --- Wiki summaries (for compiled sources) ---
cat > "$VAULT/wiki/summaries/ambient-air-pollution-dementia-meta.md" << 'EOF'
---
title: "Summary: Ambient air pollution and clinical dementia"
source_file: "raw/ambient-air-pollution-dementia-meta.md"
source_type: paper
compiled: "2026-04-07T11:00:00Z"
concepts_extracted: [pm25-dementia-risk, air-pollution-exposure]
word_count: 280
---

This BMJ systematic review and meta-analysis by Wilker et al. (2023) synthesized 51 studies examining ambient air pollution and clinical dementia risk. The strongest evidence was found for PM2.5, with a hazard ratio of 1.17 per 2 μg/m³ increase. NO2 showed consistent positive associations across studies. PM10 results were less consistent. The review used ROBINS-E for risk of bias assessment and searched major databases through July 2022. This represents the most comprehensive meta-analytic evidence to date linking ambient air pollution to dementia outcomes.
EOF

cat > "$VAULT/wiki/summaries/air-pollution-dementia-review.md" << 'EOF'
---
title: "Summary: Air Pollution and Dementia: A Systematic Review"
source_file: "raw/air-pollution-dementia-review.md"
source_type: paper
compiled: "2026-04-07T11:05:00Z"
concepts_extracted: [pm25-dementia-risk, cognitive-decline-mechanisms]
word_count: 210
---

Peters et al. (2019) conducted a systematic review of 13 cohort studies examining traffic-related air pollution and cognitive outcomes. Key findings included PM2.5 association with hippocampal volume reduction, a dose-response relationship for long-term exposure, and increased vulnerability in elderly populations and APOE4 carriers. Exposure was assessed via monitoring stations and land-use regression models.
EOF

cat > "$VAULT/wiki/summaries/lancet-dementia-prevention-2020.md" << 'EOF'
---
title: "Summary: Lancet Commission 2020 Dementia Prevention"
source_file: "raw/lancet-dementia-prevention-2020.md"
source_type: paper
compiled: "2026-04-07T11:10:00Z"
concepts_extracted: [modifiable-risk-factors, air-pollution-exposure]
word_count: 240
---

The 2020 Lancet Commission report by Livingston et al. identified 12 modifiable risk factors accounting for approximately 40% of worldwide dementia cases. Air pollution was newly added to the list with a 2% population attributable fraction. Other established factors include education, hearing loss, TBI, hypertension, excessive alcohol, obesity, smoking, depression, social isolation, physical inactivity, and diabetes. The report provides population-level evidence for prevention strategies.
EOF

# --- Wiki concepts (5 total) ---
cat > "$VAULT/wiki/concepts/pm25-dementia-risk.md" << 'EOF'
---
title: "PM2.5 and Dementia Risk"
aliases: [fine-particulate-matter-dementia, pm2.5-cognitive-decline]
created: "2026-04-07T11:00:00Z"
updated: "2026-04-07T11:05:00Z"
sources: [ambient-air-pollution-dementia-meta, air-pollution-dementia-review]
related: [air-pollution-exposure, cognitive-decline-mechanisms]
---

PM2.5 (fine particulate matter with diameter ≤2.5 μm) is the most studied air pollutant in relation to dementia risk. The meta-analytic evidence from Wilker et al. (2023) indicates a hazard ratio of 1.17 per 2 μg/m³ increase in long-term PM2.5 exposure. Peters et al. (2019) found PM2.5 associated with hippocampal volume reduction in cohort studies, with a dose-response relationship for long-term exposure. APOE4 carriers and elderly populations appear particularly vulnerable.

## Key Points
- HR 1.17 per 2 μg/m³ PM2.5 (meta-analysis of 51 studies)
- Hippocampal volume reduction observed in imaging studies
- Dose-response relationship for long-term exposure

## Source Evidence
- From [[ambient-air-pollution-dementia-meta]]: "PM2.5 associated with increased dementia risk (HR 1.17 per 2 μg/m³)"
- From [[air-pollution-dementia-review]]: "PM2.5 exposure associated with hippocampal volume reduction"

## Related Concepts
- [[Air Pollution Exposure]] — broader exposure category
- [[Cognitive Decline Mechanisms]] — downstream biological pathways
EOF

cat > "$VAULT/wiki/concepts/air-pollution-exposure.md" << 'EOF'
---
title: "Air Pollution Exposure"
aliases: [ambient-air-pollution, traffic-related-air-pollution]
created: "2026-04-07T11:00:00Z"
updated: "2026-04-07T11:10:00Z"
sources: [ambient-air-pollution-dementia-meta, lancet-dementia-prevention-2020]
related: [pm25-dementia-risk, modifiable-risk-factors]
---

Air pollution exposure encompasses several pollutants including PM2.5, PM10, NO2, and traffic-related mixtures. The 2020 Lancet Commission recognized air pollution as a modifiable dementia risk factor with a 2% population attributable fraction. Assessment methods include monitoring stations, land-use regression, and satellite-derived estimates.

## Key Points
- Multiple pollutants studied: PM2.5, PM10, NO2, traffic mix
- 2% population attributable fraction for dementia
- Various exposure assessment methods used

## Source Evidence
- From [[ambient-air-pollution-dementia-meta]]: "NO2 showed consistent positive associations; PM10 less consistent"
- From [[lancet-dementia-prevention-2020]]: "Air pollution added as new risk factor (2% PAF)"

## Related Concepts
- [[PM2.5 and Dementia Risk]] — specific pollutant evidence
- [[Modifiable Risk Factors]] — broader prevention framework
EOF

cat > "$VAULT/wiki/concepts/cognitive-decline-mechanisms.md" << 'EOF'
---
title: "Cognitive Decline Mechanisms"
aliases: [neurodegeneration-pathways, dementia-mechanisms]
created: "2026-04-07T11:05:00Z"
updated: "2026-04-07T11:05:00Z"
sources: [air-pollution-dementia-review]
related: [pm25-dementia-risk]
---

Mechanisms linking environmental exposures to cognitive decline include neuroinflammation, oxidative stress, blood-brain barrier disruption, and cerebrovascular damage. Peters et al. (2019) documented hippocampal atrophy associated with PM2.5 exposure as a structural correlate.

## Key Points
- Neuroinflammation and oxidative stress as primary pathways
- Blood-brain barrier disruption allows pollutant translocation
- Hippocampal atrophy as structural evidence

## Source Evidence
- From [[air-pollution-dementia-review]]: "PM2.5 exposure associated with hippocampal volume reduction"

## Related Concepts
- [[PM2.5 and Dementia Risk]] — exposure-outcome link
EOF

cat > "$VAULT/wiki/concepts/modifiable-risk-factors.md" << 'EOF'
---
title: "Modifiable Risk Factors"
aliases: [dementia-prevention, preventable-risk-factors]
created: "2026-04-07T11:10:00Z"
updated: "2026-04-07T11:10:00Z"
sources: [lancet-dementia-prevention-2020]
related: [air-pollution-exposure]
---

The 2020 Lancet Commission identified 12 modifiable risk factors for dementia, collectively accounting for approximately 40% of cases worldwide. Air pollution was newly included with a 2% population attributable fraction. The complete list: education (early life), hearing loss, TBI, hypertension, excessive alcohol, obesity (midlife), smoking, depression, social isolation, physical inactivity, diabetes, and air pollution (later life).

## Key Points
- 12 modifiable factors = ~40% of dementia cases
- Air pollution PAF: 2%
- Life-course approach: early, mid, and late-life factors

## Source Evidence
- From [[lancet-dementia-prevention-2020]]: "12 modifiable risk factors account for ~40% of dementia cases"

## Related Concepts
- [[Air Pollution Exposure]] — one of the 12 factors
EOF

cat > "$VAULT/wiki/concepts/project-timeline.md" << 'EOF'
---
title: "Project Timeline"
aliases: [research-timeline]
created: "2026-04-07T11:15:00Z"
updated: "2026-04-07T11:15:00Z"
sources: []
related: []
---

Placeholder concept for project planning and milestones. Currently has no source evidence.
EOF

# --- State, backlinks, agent, preferences, sources ---
cat > "$VAULT/wiki/.state.json" << 'EOF'
{"version": 1, "last_compiled": "2026-04-07T11:10:00Z", "last_lint": null, "last_rebuilt": "2026-04-07T11:15:00Z", "stats": {"source_count": 5, "compiled_count": 3, "pending_count": 2, "concept_count": 5, "summary_count": 3, "output_count": 0}}
EOF

cat > "$VAULT/wiki/_backlinks.json" << 'EOF'
{"ambient-air-pollution-dementia-meta": ["pm25-dementia-risk", "air-pollution-exposure"], "air-pollution-dementia-review": ["pm25-dementia-risk", "cognitive-decline-mechanisms"], "lancet-dementia-prevention-2020": ["air-pollution-exposure", "modifiable-risk-factors"], "air-pollution-exposure": ["pm25-dementia-risk", "modifiable-risk-factors"], "pm25-dementia-risk": ["air-pollution-exposure", "cognitive-decline-mechanisms"], "cognitive-decline-mechanisms": ["pm25-dementia-risk"], "modifiable-risk-factors": ["air-pollution-exposure"]}
EOF

cat > "$VAULT/agent.md" << 'EOF'
---
title: Vault Agent
version: 1
updated: null
vault_stats:
  total_queries: 0
  total_compiles: 1
  cache_hits: 0
  tier3_fallbacks: 0
---

## Concept Clusters

_No clusters discovered yet._

## Query Patterns

_No patterns recorded yet._

## Source Signals

- ambient-air-pollution-dementia-meta: meta-analysis, PM2.5, dementia-risk | cited: 0
- air-pollution-dementia-review: systematic-review, traffic-pollution, cognitive | cited: 0
- lancet-dementia-prevention-2020: prevention, modifiable-risk, lancet | cited: 0

## Corrections

_No corrections logged._
EOF

cat > "$VAULT/preferences.md" << 'EOF'
---
title: Vault Preferences
updated: "2026-04-07T10:00:00Z"
---

## Domain
Environmental epidemiology — air pollution and neurodegeneration

## Source Priority
Peer-reviewed meta-analyses > systematic reviews > cohort studies > editorials

## Concept Granularity
Balanced

## Compilation Focus
Always extract quantitative data (HRs, CIs, p-values, sample sizes). Note study design and exposure assessment methods.

## Custom Rules
Prioritize PM2.5 evidence. Flag APOE4 interactions when present.
EOF

cat > "$VAULT/sources.json" << 'EOF'
{"version": 1, "configured_sources": [], "last_configured": null}
EOF

# --- Rebuild index via script ---
PLUGIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
if [ -f "$PLUGIN_DIR/scripts/rebuild-index.sh" ]; then
    VAULT_DIR="$VAULT" bash "$PLUGIN_DIR/scripts/rebuild-index.sh" "$VAULT" 2>/dev/null
fi

echo "Test vault created at $VAULT with 5 sources (3 compiled, 2 pending), 5 concepts."
