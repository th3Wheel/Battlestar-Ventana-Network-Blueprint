# GitHub Copilot Instructions — Battlestar Ventana Network Blueprint

## 🎯 Repository Overview

**Type:** Documentation-only repository (NO build/compile/test steps)  
**Size:** ~9MB, 1,762 lines across 11 core docs  
**Purpose:** Network infrastructure documentation for home/lab network with Battlestar Galactica themed VLAN naming  
**IP Scheme:** `10.76.X.0/24` where X = VLAN ID  

**Tech Stack:** Markdown, YAML, JSON, Mermaid diagrams, Git with semantic versioning

---

## 🛠️ Build, Validation & Testing

### CRITICAL: No Build Process
This is documentation-only. **NO** npm install, pip install, make, compile, or test suite exists.

### Validation Commands (Run Before Committing)

**1. Markdown Linting** (ALWAYS run when modifying `.md` files):

```bash
npx markdownlint-cli2 "**/*.md" "#node_modules"
```

Modern linter installed: `markdownlint-cli2` v0.20.0  
Config files: `.markdownlintrc.json` (rules) + `.markdownlint-cli2.jsonc` (CLI config)

To install globally: `npm install -g markdownlint-cli2`

**Auto-fix** markdown errors:

```bash
npx markdownlint-cli2 --fix "**/*.md"
```

**2. YAML Validation** (ALWAYS run when modifying `.yaml` or `.yml` files):
```bash
python3 -c "
import yaml, sys
for f in ['alerts/Alertmanager style.yaml', 'ha/lovelace.yaml', 'ha/dasboard..yaml']:
    yaml.safe_load(open(f)); print(f'✓ {f}')
"
```

**3. JSON Validation** (ALWAYS run when modifying `.json` files):

```bash
python3 -c "
import json
for f in ['.markdownlintrc.json', '.vscode/settings.json']:
    json.load(open(f)); print(f'✓ {f}')
"
```

### Validation Order
1. Make documentation changes
2. Run markdown linter: `npx markdownlint-cli2 "**/*.md" "#node_modules"`
3. Run YAML validation if modified YAML
4. Run JSON validation if modified JSON
5. Update `CHANGELOG.md` in `[Unreleased]` section
6. Verify VLAN IDs/IPs consistent across all docs

### Common Errors & Fixes

**YAML Error:** `mapping values are not allowed here` → Check 2-space indentation (no tabs)  
**JSON Error:** `Expecting ',' delimiter` → Remove trailing commas  
**Symlink Error:** `infrastructure` broken → DO NOT modify (points to external Obsidian vault)  
**Markdown MD013:** Line too long → Max 320 chars (configured in `.markdownlintrc.json`)  
**Note**: Relaxed rules in `.markdownlintrc.json` for compact docs (MD022, MD031, MD032, MD040 disabled)

---

## 📂 Project Layout & Key Files

### Directory Structure

```
├── readme.md (lowercase!)          # Master blueprint, VLAN map, quick audit
├── CHANGELOG.md                    # ALWAYS update [Unreleased] for ANY change
├── .markdownlintrc.json            # Markdown linting rules (320 char limit)
├── .markdownlint-cli2.jsonc        # Modern linter config (extends .markdownlintrc.json)
├── docs/                           # Core documentation (1,762 total lines)
│   ├── Project_Architecture_Blueprint.md  # 468 lines - Full architecture
│   ├── firewall-matrix.md          # 294 lines - VLAN access matrix with symbols
│   ├── naming-conventions.md       # 45 lines - CRITICAL: All naming rules
│   ├── dhcp-scopes.md              # 29 lines - Subnet ranges, gateways
│   ├── services.md                 # 124 lines - Service/port mappings (has TODOs)
│   ├── audit-checklist.md          # 24 lines - Operational health
│   ├── hardening-rollout-plan.md   # 679 lines - Security hardening
│   ├── host-tracker.md, physical-hosts.md, other-devices.md, jaeger-pool.md
│   └── raw/network.md
├── alerts/Alertmanager style.yaml  # Prometheus alerts (2-space YAML)
├── ha/                             # Home Assistant config
│   ├── lovelace.yaml, dasboard..yaml (typo in name - leave as-is)
│   └── guidelines/
├── dashboards/                     # Grafana dashboards, mockups
├── baseline/                       # Architectural design docs, deployment guides
├── plan/                           # Feature planning documents
└── infrastructure -> (symlink)     # DO NOT TOUCH: External Obsidian vault
```

### Network Architecture Quick Reference

**11 VLANs:** 10, 20, 30, 31, 40, 50, 60, 70, 81, 82, 90  
**IP Scheme:** `10.76.X.0/24`, gateway always `.1`  
**Theme:** Battlestar Galactica (see `docs/naming-conventions.md`)

| VLAN | Name | Purpose | Zone |
|------|------|---------|------|
| 10 | Battlestar Ventana | Trusted LAN | Trusted |
| 20 | CylonSynthLink | IoT devices | Untrusted (highly restricted) |
| 30 | CapricaGuestPortal | Guest network | Untrusted (Internet only) |
| 31 | PiconResidentGate | Elevated guest | Semi-Trusted (cast/print) |
| 40 | Basestar Control | Infrastructure | Infrastructure (mgmt plane) |
| 50 | GemenonServiceVault | NAS/MQTT/HA | Services (central hub) |
| 60 | VirgonFleetYard | Printers | Semi-Trusted |
| 70 | PegasusMediaNode | Media/Casting | Semi-Trusted |
| 81 | ScorpiaMediaShield | Cameras Local | Surveillance (view-only) |
| 82 | ScorpiaMediaRelay | Cameras Cloud | Surveillance (view-only) |
| 90 | ScyllaProcessControl | Work VLAN | Trusted (VPN access) |

### Firewall Matrix Symbols (used in `docs/firewall-matrix.md`)
- ✅ Full access
- 🟡 Limited access (specific ports/services)
- 🔵 View-only (monitoring, read-only)
- ❌ Blocked
- 🌐 Internet access

---

## 📋 Naming Conventions (CRITICAL - Follow Strictly)

From `docs/naming-conventions.md`:

1. **VLANs/SSIDs:** Battlestar Galactica themed, space-separated capitals  
   Example: `Battlestar Ventana`, `CylonSynthLink`

2. **Physical Hosts:** `<Color/Element><Descriptor>` (PascalCase)  
   Example: `CrimsonRogue`, `MintRedoubt` - Unique per chassis, **never reused**

3. **Personal Computers:** Pacific Rim Jaegers (PascalCase)  
   Pool: `GipsyDanger`, `StrykerEureka`, `ChernoAlpha`, `CoyoteTango`, etc.  
   May recycle only for direct replacement

4. **Other Devices:** `<zone>-<role>-<index>` (lowercase, hyphen-separated)  
   Roles: `ctrl`, `sens`, `cast`, `stor`, `view`, `print`, `relay`, `edge`  
   Example: `iot-sens-01`, `media-cast-02`, `printer-print-01`

---

## ✅ Documentation Standards

### Markdown Style
- Use emoji prefixes: 🔐 security, 📡 network, 🛠️ tools, 📊 monitoring, 📂 structure
- H1 for title, H2 for major sections, H3 for subsections
- Horizontal rules `---` between major sections
- Tables for structured data (firewall rules, VLAN mappings)
- Mermaid diagrams for network flows/topology

### YAML Style
- 2-space indentation (NO tabs)
- Lowercase with hyphens for keys
- Follow patterns in `alerts/` and `ha/`

### CHANGELOG.md Updates (MANDATORY)
- Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format
- Categories: Added, Changed, Deprecated, Removed, Fixed, Security
- **ALWAYS** update `[Unreleased]` section for ANY change
- Include specific file references

Example:
```markdown
## [Unreleased]

### Added
- **`docs/new-feature.md`** - Documentation for feature X

### Changed
- **VLAN 20 firewall rules** in `firewall-matrix.md` - Added port 8883 for MQTT
```

---

## 🚫 Protected Elements (DO NOT MODIFY)

1. **`infrastructure` symlink** - Points to external Obsidian vault, leave as-is
2. **Historical `CHANGELOG.md` entries** - Only add to `[Unreleased]`, never modify past releases
3. **Existing VLAN IDs** - Don't change without explicit instruction (requires updates across ALL docs)
4. **`docs/naming-conventions.md`** - Only change after discussion (affects entire naming scheme)
5. **Visual assets (PNG files)** - Only replace, don't delete without replacements
6. **File `ha/dasboard..yaml`** - Typo in filename, but leave as-is (changing breaks HA config)

---

## 🎯 Common Workflows

### Adding a New VLAN
1. Choose Battlestar-themed name (check [Battlestar Wiki](https://battlestarwiki.org/))
2. Assign next available VLAN ID, subnet `10.76.X.0/24`, gateway `.1`
3. Update `docs/dhcp-scopes.md` with subnet details
4. Add firewall rules to `docs/firewall-matrix.md` (use symbols: ✅🟡🔵❌🌐)
5. Update Mermaid diagrams in relevant docs
6. Add to `docs/services.md` with port/protocol details
7. Update `readme.md` VLAN list
8. Update `CHANGELOG.md` under `[Unreleased]` → `### Added`
9. Run markdown linter: `npx markdownlint-cli2 "**/*.md"`

### Updating Firewall Rules
1. Update `docs/firewall-matrix.md` access matrix table
2. Add port/protocol to Service/Ports Reference Table
3. Update Mermaid diagrams showing traffic flow
4. Document justification in notes section
5. Consider bidirectional rules (source ↔ destination)
6. Update `CHANGELOG.md` under `[Unreleased]` → `### Changed`
7. Run markdown linter

### Adding Documentation
1. Create file in appropriate directory (`docs/`, `baseline/`, `plan/`)
2. Use emoji-prefixed H1 header matching repo style
3. Include `---` separators between major sections
4. Add reference link in `readme.md` if appropriate
5. Update `CHANGELOG.md` under `[Unreleased]` → `### Added`
6. Run markdown linter: `npx markdownlint-cli2 "**/*.md"`

---

## 🔍 Validation Checklist (Before Every Commit)

- [ ] Run markdown linter: `npx markdownlint-cli2 "**/*.md" "#node_modules"`
- [ ] Run YAML validation if modified `.yaml` files
- [ ] Run JSON validation if modified `.json` files
- [ ] Updated `CHANGELOG.md` under `[Unreleased]`
- [ ] Verified VLAN IDs consistent across all docs
- [ ] Checked emoji usage matches existing patterns
- [ ] Confirmed internal links work (markdown references to other docs)
- [ ] Verified firewall matrix symbols used correctly
- [ ] Ensured Mermaid diagram syntax is valid
- [ ] Followed naming conventions from `docs/naming-conventions.md`

---

## 📚 Key Reference Files

**Must-read before making changes:**
- `readme.md` - Overview, VLAN mapping, quick audit
- `docs/naming-conventions.md` - ALL naming rules
- `docs/firewall-matrix.md` - Access matrix symbols and rules
- `CHANGELOG.md` - Change history format

**Architecture deep-dives:**
- `docs/Project_Architecture_Blueprint.md` - Complete architecture (468 lines)
- `docs/hardening-rollout-plan.md` - Security procedures (679 lines)

**Configuration references:**

- `.markdownlintrc.json` - Markdown linting rules (standard format)
- `.markdownlint-cli2.jsonc` - CLI config (extends .markdownlintrc.json)
- `docs/dhcp-scopes.md` - Subnet configuration
- `docs/services.md` - Service/port mappings

---

## 💡 Trust These Instructions

These instructions have been validated by:

1. Running documented validation commands on key files
2. Exploring all 17 files in root directory
3. Reviewing all 11 documentation files in `docs/`
4. Testing YAML/JSON validation with Python
5. Verifying repository structure and symlinks
6. Understanding Battlestar Galactica naming theme

**If you need to explore further:** Only do so if these instructions are incomplete or found to be in error. Otherwise, trust this guidance and proceed efficiently.

---

**Last Updated:** 2026-01-26  
**Instructions Version:** 1.0
