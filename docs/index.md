# Sustainable Factory Documentation

Welcome to the Sustainable Factory project documentation.

```{toctree}
:hidden:

search
```

{doc}`Search <search>`

## Sustainable Factory Project
```{toctreeyaml}
:maxdepth: 3
:caption: Table of Contents:
:file: _toc.yml
```
- {ref}`tables_and_figures`

## `sustainablefactory` Software
This project uses MyST Markdown and JSON to capture and model sustainable process and product information and generates RDF linked data.

This system parses industrial process descriptions (like [paper.myst.md](paper.myst.md)) and converts them into a structured graph linked data representation
using the **Industrial Ontologies Foundry (IOF)** and sustainablefactory process schema.
[ [schema](schema.md) ]

- **Parser**: Extracts steps, properties, and Mermaid diagrams.
- **RDF Generator**: Produces Turtle RDF (`.ttl`) with reified confidence metrics.
- **Visualizer**: Integrated Mermaid diagrams for process flow overview.

## `sustainablefactory` research

- Source chats
  - `data/chats/*.{md,json}`
- Domains / fields / applications / areas of study
  - Applied physics
  - Applied electrical engineering
  - Applied computer science
  - Applied information systems
  - Applied AI
  - Sustainable materials
  - Sustainable process development
  - Sustainable manufacturing
  - Sustainable computing
  - Quantum computing
    - [Sustainable Quantum architecture](paper.myst.md)
    - [Soliton bus model](soliton-bus.md): finite multiplexing, routing, and
      operator contracts with chat-derived evidence boundaries.
- [Chat physics catalog](chat-physics-catalog.md): applications, processes,
  products, evidence status, and prioritized Signals-model update candidates.




### sustainablefactory research methods

- (AI) Research Methods
  - {download}`Research evidence triage skill <../.agents/skills/research-evidence-triage/SKILL.md>`:
    reproducible chat searches, scholarly provenance, and claim-level citations.
  - {download}`Signals evidence modeling skill <../.agents/skills/signals-evidence-modeling/SKILL.md>`:
    evidence disposition, Pending boundaries, focused tests, and documentation
    updates.
  - Agent guidance
    - {download}`AGENTS.md <../AGENTS.md>`
    - {download}`src/signals/AGENTS.md <../src/signals/AGENTS.md>`
    - {download}`src/wrd-sphinx-theme/AGENTS.md <../src/wrd-sphinx-theme/AGENTS.md>`
    - Third-party Agent guidance
      - {download}`src/agentsview/AGENTS.md <../src/agentsview/AGENTS.md>`
      - {download}`src/agentsview/frontend/AGENTS.md <../src/agentsview/frontend/AGENTS.md>`
      - {download}`src/oxigraph/AGENTS.md <../src/oxigraph/AGENTS.md>`
      - {download}`src/physlib/AGENTS.md <../src/physlib/AGENTS.md>`
  - Instructions
    - {download}`chat-citations.instructions.md <../.github/instructions/chat-citations.instructions.md>`
    - {download}`use-local-tmp.instructions.md <../.github/instructions/use-local-tmp.instructions.md>`
  - Skills
    - {download}`search-chats/SKILL.md <../.agents/skills/search-chats/SKILL.md>`
    - {download}`search-chats-sources/SKILL.md <../.agents/skills/search-chats-sources/SKILL.md>`
    - {download}`upgrade-versions-pyproject/SKILL.md <../.agents/skills/upgrade-versions-pyproject/SKILL.md>`
    - {download}`src/agentsview/.agents/skills/localization-paraglide/SKILL.md <../src/agentsview/.agents/skills/localization-paraglide/SKILL.md>`
    - {download}`src/agentsview/.agents/skills/testing-without-tautologies/SKILL.md <../src/agentsview/.agents/skills/testing-without-tautologies/SKILL.md>`
    - {download}`src/agentsview/.claude/skills/localization-paraglide/SKILL.md <../src/agentsview/.claude/skills/localization-paraglide/SKILL.md>`
    - {download}`src/agentsview/.claude/skills/testing-without-tautologies/SKILL.md <../src/agentsview/.claude/skills/testing-without-tautologies/SKILL.md>`

- See {ref}`readme`
