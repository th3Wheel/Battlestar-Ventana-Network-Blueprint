---
name: led-analysis
description: Processes LED strip, panel, and module product data into structured analysis, wiring guidance, and alternative recommendations. Use when asked to analyze LED products, interpret LED strip specifications, generate wiring diagrams, evaluate chipset compatibility, or recommend compatible LED controllers and power supplies.
license: Complete terms in LICENSE.txt
---

# LED Analysis Skill

The LED Analysis skill interprets LED strip, panel, and module product data and
produces structured, deterministic outputs. It applies realistic chipset and voltage
conventions, validates inputs through schemas, formats outputs using templates, and
enforces consistency through linting rules. The skill is designed for reproducibility,
auditability, and integration into larger automation or documentation workflows.

## Version

- 1.0.0

## Inputs

- product_name: string
- product_description: string
- voltage: number | null
- chipset: string | null
- power_watts: number | null
- length_meters: number | null
- connector_type: string | null

## Outputs

- analysis.md
- wiring.md
- alternatives.md

## Activation

- Required fields:
  - product_name
  - product_description

## Conventions, Templates, and Schemas

- Conventions reference: CONVENTIONS.md
- Templates:
  - analysis: analysis.md
  - wiring: wiring.md
  - alternatives: alternatives.md
- Schemas:
  - input: schema/input.schema.json
  - output: schema/output.schema.json

## Examples and Tests

- Examples directory: examples/
- Tests directory: tests/

## Folder Map

.github/skills/led-analysis/
alternatives.md
analysis.md
CONVENTIONS.md
SKILL.md
wiring.md
wiring_template.mmd
examples/
analysisBasic.md
alternativesBasic.md
fullRunPanel.md
fullRunStrip.md
fullRunUnknown.md
wiringBasic.md
lint/
lint.py
lint_rules.md
schema/
input.schema.json
output.schema.json
tests/
panel.json
strip.json
unknown.json

## Relevant Information

SKILL.md defines the skill's purpose, activation requirements, and expected behavior.
CONVENTIONS.md documents realistic chipset, voltage, connector, and wiring assumptions used when product data is incomplete.
Templates (analysis.md, wiring.md, alternatives.md) define the structure of generated outputs.
Schemas (input.schema.json, output.schema.json) validate incoming data and ensure generated outputs follow the required structure.
Linting (lint_rules.md, lint.py) enforces formatting, structure, and naming conventions across generated files.
Examples illustrate correct usage and serve as reference outputs for common product types.
Test cases provide structured inputs for validating behavior across strips, panels, and unknown products.
wiring_template.mmd provides a reusable Mermaid diagram scaffold for wiring outputs.

The skill is deterministic: given the same input, it will always produce the same outputs.
