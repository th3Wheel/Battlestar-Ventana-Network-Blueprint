# LED Analysis Subsystem

The LED Analysis subsystem interprets LED strip, panel, and module product data and produces structured, deterministic outputs. It applies realistic chipset and voltage conventions, validates inputs through schemas, formats outputs using templates, and enforces consistency through linting rules. The subsystem is designed for reproducibility, auditability, and integration into larger automation or documentation workflows.

The module processes raw product descriptions into three standardized documents:
- analysis.md — electrical, physical, and compatibility analysis
- wiring.md — wiring, power, and controller guidance
- alternatives.md — compatible and improved product recommendations

Schemas ensure inputs and outputs follow strict structure. Examples demonstrate correct behavior. Test cases validate the subsystem across common product categories. Conventions define realistic assumptions when product data is incomplete or ambiguous.

## Folder Map
skills/led_analysis/
  alternatives.md
  analysis.md
  CONVENTIONS.md
  README.md
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
SKILL.md defines the subsystem’s purpose, activation requirements, and expected behavior.
CONVENTIONS.md documents realistic chipset, voltage, connector, and wiring assumptions used when product data is incomplete.
Templates (analysis.md, wiring.md, alternatives.md) define the structure of generated outputs.
Schemas (input.schema.json, output.schema.json) validate incoming data and ensure generated outputs follow the required structure.
Linting (lint_rules.md, lint.py) enforces formatting, structure, and naming conventions across all generated files.
Examples illustrate correct usage and serve as reference outputs for common product types.
Test cases provide structured inputs for validating subsystem behavior across strips, panels, and unknown products.
wiring_template.mmd provides a reusable Mermaid diagram scaffold for wiring outputs.

The subsystem is deterministic: given the same input, it will always produce the same outputs. All files listed in the folder map are required for correct operation.