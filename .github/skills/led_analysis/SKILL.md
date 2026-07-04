---
name: led-analysis
description: Processes LED strip, panel, and module product data into structured analysis, wiring guidance, and alternative recommendations. Use when asked to analyze LED products, interpret LED strip specifications, generate wiring diagrams, evaluate chipset compatibility, or recommend compatible LED controllers and power supplies.
license: Complete terms in LICENSE.txt
---

# LED Analysis Skill

version: 1.0.0

inputs:
  - product_name: string
  - product_description: string
  - voltage: number | null
  - chipset: string | null
  - power_watts: number | null
  - length_meters: number | null
  - connector_type: string | null

outputs:
  - analysis.md
  - wiring.md
  - alternatives.md

activation:
  required_fields:
    - product_name
    - product_description

conventions:
  reference: CONVENTIONS.md

templates:
  analysis: analysis.md
  wiring: wiring.md
  alternatives: alternatives.md

schemas:
  input: schema/input.schema.json
  output: schema/output.schema.json

examples:
  directory: examples/

tests:
  directory: tests/
