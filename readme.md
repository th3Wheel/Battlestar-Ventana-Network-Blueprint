# 💠 Battlestar Ventana Network Blueprint

[![AI Ready](https://img.shields.io/badge/AI--Ready-yes-brightgreen?style=flat)](https://github.com/johnpapa/ai-ready)

**IP Scheme:** `10.76.X.0/24` (X = VLAN ID)  
**Theme:** Colonies & ships from Battlestar Galactica, mapped to VLANs for instant auditability.  
**Status:** unknown

---

## 📡 VLAN / SSID mapping

- **Battlestar Ventana (10):** Trusted LAN
- **CylonSynthLink (20):** IoT devices
- **CapricaGuestPortal (30):** Guest – Internet only
- **CapricaResidentPortal (31):** Elevated guest (casting, printing)

- **BasestarVentana (40):** Infrastructure switches/controllers
- **GemenonServiceVault (50):** NAS, MQTT, Home Assistant
- **VirgonFleetYard (60):** Printers
- **PegasusMediaNode (70):** Media / Casting
- **ScorpiaMediaShield (81):** Cameras – Local
- **ScorpiaMediaRelay (82):** Cameras – Cloud
- **ScyllaProcessControl (90):** Work VLAN

---

## 🔐 Firewall matrix

See [`docs/firewall-matrix.md`](docs/firewall-matrix.md)

## 📊 Monitoring & dashboards

- Grafana: [`dashboards/dashboard.json`](dashboards/dashboard.json)  
- Prometheus: [`alerts/alert_rules.yaml`](alerts/alert_rules.yaml)  
- Home Assistant: [`ha/lovelace.yaml`](ha/lovelace.yaml)
- Homepage mockup: [`dashboards/Homepage Mockup.md`](dashboards/Homepage%20Mockup.md)

## 📚 Supporting documentation

- [`docs/tech-stack-baseline.md`](docs/tech-stack-baseline.md) — Canonical tech stack reference for humans and agents
- [`docs/naming-conventions.md`](docs/naming-conventions.md) — SSID/VLAN naming rules
- [`docs/dhcp-scopes.md`](docs/dhcp-scopes.md) — Subnet ranges, gateways, lease times
- [`docs/audit-checklist.md`](docs/audit-checklist.md) — Operational health checklist
- [`docs/services.md`](docs/services.md) — Service/ports traffic matrix (per‑VLAN service flows)
- [`docs/host-tracker.md`](docs/host-tracker.md) — Canonical host tracker index
- [`docs/other-devices.md`](docs/other-devices.md) — IoT, printers, cameras, and appliances tracker
- [`docs/wled-configurations.md`](docs/wled-configurations.md) — WLED LED strip configurations and presets
- [`docs/hyperion-camera-sensor.md`](docs/hyperion-camera-sensor.md) — ESP32 Hyperion HD camera sensors for ambient lighting
- [`CHANGELOG.md`](CHANGELOG.md) — Versioned history of changes

---

## 🧪 Audit checklist (quick view)

- **Guest VLAN:** Isolated from LANs  
- **IoT VLAN:** Restricted to telemetry only  
- **Cameras:** View‑only from Trusted  
- **Work VLAN (90):** Unthrottled Internet; VPN bootstraps via local DNS/DHCP  
- **ServerVault:** Outbound limited to updates and sync

---

## 📂 Repo structure

```tree
Battlestar-Ventana-Network-Blueprint/
├── readme.md                 # Master blueprint doc (VLANs, zones, diagrams, audit checklist)
│
├── dashboards/               # Grafana dashboards
│   ├── dashboard.json
│   └── README.md
│
├── alerts/                   # Prometheus alert rules
│   ├── alert_rules.yaml
│   └── README.md
│
├── ha/                       # Home Assistant Lovelace dashboard
│   ├── lovelace.yaml
│   └── README.md
│
└── docs/                     # Supporting documentation
    ├── firewall-matrix.md    # VLAN + Zone firewall rules, Internet Access Policy, audit tie-in
    ├── dhcp-scopes.md        # Subnet ranges, gateways, lease times
    ├── naming-conventions.md # Canonical SSID/VLAN naming rules
    ├── audit-checklist.md    # Operational health checklist
    └── services.md           # Service/ports traffic matrix (scaffolded, TODOs for detail)
CHANGELOG.md                  # Versioned history of changes
```

### 📑 Legend

- 📄 Documentation  
- 📊 Dashboards  
- ⚙️ Configs / Alerts  

---

## Developer checks

The repository's validation tools require Node.js 26.10.0 or later, npm, `uv`,
and Docker with a running Linux container engine. From the repository root:

- Run `npm ci` to install the locked dependencies.
- Run `npm test` to execute the Vitest test suite.
- Run `npm run lint:md` to lint Markdown files with ESLint.
- Run `npm run lint:eslint` to lint JavaScript, TypeScript, JSON, CSS, and Markdown files.
- Run `npm run lint:eslint:fix` to apply ESLint fixes to supported files; use
  `npm run lint:js:fix` or `npm run lint:md:fix` for a focused fix.
- Run `npm run lint:python` to run Ruff linting, formatting checks, and ty type checks.
- Run `npm run lint:python:fix` to apply Ruff fixes and formatting.
- Run `npm run lint:yaml` to run the project-managed yamllint through `uv`;
  no global yamllint installation or virtual-environment activation is needed.
- Run `npm run lint:shell` to run ShellCheck on repository shell scripts.
- ShellCheck runs only through Docker; no native installation is needed.
  The [official ShellCheck image](https://github.com/koalaman/shellcheck#installing)
  is pinned by version and immutable digest in `.shellcheck-image`. The wrapper
  verifies `.shellcheck-version` (currently `0.11.0`), explicitly loads
  `.shellcheckrc`, and clears `SHELLCHECK_OPTS`. It mounts the repository read-only,
  disables container networking, and reports all severities in GCC format while
  preserving script-level directives. Docker may download the image on first use;
  offline runs require the pinned image to be cached. Start Docker Desktop with
  Linux containers before running the check. Update both pin files together when
  upgrading ShellCheck; there is no native fallback.
  Git enforces LF line endings for `.shellcheckrc` and shell scripts so the
  Linux container can read them correctly on Windows checkouts.
- ShellCheck has no automatic fix mode. `yamllint` findings must be fixed
  manually; use `npm run format:yaml` to apply Prettier formatting.
- YAML formatting includes `.yamllint`, using an explicit YAML parser override.
- Run `npm run lint` to run ESLint, YAML, Python, shell, and YAML formatting
  checks; run `npm run fix` to apply supported ESLint, Ruff, and YAML formatting
  fixes.

Pass tool-specific options after `--`, for example
`npm run lint:eslint -- --fix`. `npm run lint` is check-only; use `npm run fix`
to apply all configured automatic fixes.

The Markdown rules that currently flag legacy template/reference findings are
temporarily deferred; see [issue #127](https://github.com/th3Wheel/Battlestar-Ventana-Network-Blueprint/issues/127).

### Python and Ansible environments

- The root `pyproject.toml` and `uv.lock` are authoritative for Python development
  tools. Run `uv sync --locked` from the repository root. Do not manually install
  Ansible into this environment: synchronization removes undeclared packages.
- Ruff replaces Black, isort, and Pylint in the root toolchain; ty provides
  separate type checking. Ruff's selected rules do not cover every Pylint check.
- `requirements.txt` is a generated compatibility export, not an independent
  dependency source. Regenerate it after dependency changes with
  `uv export --locked --no-hashes --no-emit-project --format requirements-txt --output-file requirements.txt`.
- The Linux/WSL Ansible development controller has its own manifest and lockfile
  in `ansible/controller/`, using Python 3.14 and Ansible Core 2.21.3.
  From the repository root in Linux/WSL, run
  `uv sync --project ansible/controller --locked`. Run controller tools with
  `uv run --project ansible/controller --locked ansible --version`;
  substitute `ansible-lint`, `molecule`, or `ansible-playbook` as needed.
- Native Windows is not an Ansible control node. Do not share a virtual
  environment between Windows and WSL; keep a separate Linux checkout/environment.
  See the [Ansible controller requirements](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-node-requirements).
- The legacy deployment execution environment still uses
  `ansible/requirements.txt`, Python 3.11, and its existing Core constraints.
  It is not upgraded by the development controller change. The legacy
  `ansible/bootstrap-env.ps1` helper is not the new controller bootstrap;
  use `task ansible:bootstrap` from Linux/WSL instead.
- If uv warns about `VIRTUAL_ENV=.venv\.venv`, deactivate the stale environment
  and open a fresh terminal. VS Code's Python project points at the repository
  root, not the `.venv` directory. Do not use `--active` to redirect project
  synchronization into the accidental nested environment.

---

🚀 *The Battlestar Ventana Network Blueprint now documents VLANs, firewall rules, Internet policy, service flows, audit checks, and versioned history in one cohesive repo.*

## Contributing

1. Create a focused topic branch from the repository's default branch.
2. Make related changes together and update affected documentation.
3. Run `npm ci`, `npm test`, and `npm run lint` from the repository root.
4. For MCP configuration changes, also run `npm run mcp:sync-check`.
5. Open a pull request with the provided template. Keep secrets and private
   network details out of issues, logs, and pull request descriptions.

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the contribution and review
guidance.
