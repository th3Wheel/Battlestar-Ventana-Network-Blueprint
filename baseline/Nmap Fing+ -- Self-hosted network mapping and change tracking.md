# Nmap Fing+ -- Self-hosted network mapping and change tracking# Nmap Fing+ -- Self-hosted network mapping and change trackingA zero-cost, self-hosted ---

A zero-cost, self-hosted system to discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable "block" commands—now with a modern web dashboard for real-time network monitoring and management.

Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]  A zero-cost, self-hosted system to discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable "block" commands—now with a modern web dashboard for real-time network monitoring and management.## Architecture and components

Link to the Dashboard deployment guide: [[Nmap Fing+ Dashboard Deployment Guide]]

---

Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]  ### Core Scanning Infrastructure

## Project summary

Link to the Dashboard deployment guide: [[Nmap Fing+ Dashboard Deployment Guide]]- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.

- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.

- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket.---- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.

---- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.

## Architecture and components## Project summary- **Alerts (optional):** ntfy or email notifications for newly detected devices

### Core Scanning Infrastructure- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables

- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).### Web Dashboard Infrastructure

- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.

- **Alerts (optional):** ntfy or email notifications for newly detected devices.- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables.

- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket.- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.

### Web Dashboard Infrastructure

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.---- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.

- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.

- **Network topology:** Interactive graph showing device relationships and network segments.## Architecture and components- **Network topology:** Interactive graph showing device relationships and network segments.

- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.

- **Device management:** Quick access to block commands and device details from web interface.- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.

### Data Flow### Core Scanning Infrastructure- **Device management:** Quick access to block commands and device details from web interface

1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates

3. **Web clients** → Receive real-time updates → Display network status and changes- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.### Data Flow

---- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

## Scripts- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates

[[install_nmap_fingplus.sh]]- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.3. **Web clients** → Receive real-time updates → Display network status and changes discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable "block" commands—now with a modern web dashboard for real-time network monitoring and management.

[[nmap_fingplus_git.sh]]

[[install_dashboard.sh]]- **Alerts (optional):** ntfy or email notifications for newly detected devices.

[[dashboard_app.py]]

[[sync_dashboard.sh]]- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables.Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]  

Link to the Dashboard deployment guide: [[Nmap Fing+ Dashboard Deployment Guide]]

### Web Dashboard Infrastructure

---

- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.## Project summary

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).

- **Network topology:** Interactive graph showing device relationships and network segments.- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.

- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket. self-hosted system to discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable “block” commands—ready for Obsidian later but not required now.

- **Device management:** Quick access to block commands and device details from web interface.

Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]

### Data Flow

---

1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates## Project summary

3. **Web clients** → Receive real-time updates → Display network status and changes

- **Goal:** Map your network, keep it current, highlight service changes, and log everything in Git for full auditability.

---- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).

- **Outputs:** Per-scan Markdown summaries and per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, and quick block commands.

## Scripts- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices

[[install_nmap_fingplus.sh]]---

[[nmap_fingplus_git.sh]]## Architecture and components

[[install_dashboard.sh]]

[[dashboard_app.py]]- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.

[[sync_dashboard.sh]]- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.
- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.
- **Alerts (optional):** ntfy or email notifications for newly detected devices.
- **Actionability:** Per-host “Quick Block Commands” for fast isolation via iptables/ebtables.

---

## Scripts

[[install_nmap_fingplus.sh]]
[[nmap_fingplus_git.sh]]

## Action Plan for Self-hosted network mapping and change tracking

### Core Scanning Infrastructure

## Project summary

- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.

- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.

- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket.---- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.

---- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.

## Architecture and components## Project summary- **Alerts (optional):** ntfy or email notifications for newly detected devices

### Core Scanning Infrastructure- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables

- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).### Web Dashboard Infrastructure

- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.

- **Alerts (optional):** ntfy or email notifications for newly detected devices.- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables.

- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket.- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.

### Web Dashboard Infrastructure

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.---- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.

- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.

- **Network topology:** Interactive graph showing device relationships and network segments.## Architecture and components- **Network topology:** Interactive graph showing device relationships and network segments.

- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.

- **Device management:** Quick access to block commands and device details from web interface.- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.

### Data Flow### Core Scanning Infrastructure- **Device management:** Quick access to block commands and device details from web interface

1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates

3. **Web clients** → Receive real-time updates → Display network status and changes- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.### Data Flow

---- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

## Scripts- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates

[[install_nmap_fingplus.sh]]- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.3. **Web clients** → Receive real-time updates → Display network status and changes discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable "block" commands—now with a modern web dashboard for real-time network monitoring and management.

[[nmap_fingplus_git.sh]]

[[install_dashboard.sh]]- **Alerts (optional):** ntfy or email notifications for newly detected devices.

[[dashboard_app.py]]

[[sync_dashboard.sh]]- **Actionability:** Per-host "Quick Block Commands" for fast isolation via iptables/ebtables.Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]  

Link to the Dashboard deployment guide: [[Nmap Fing+ Dashboard Deployment Guide]]

### Web Dashboard Infrastructure

---

- **Dashboard LXC host:** Separate container running Flask web application with SQLite cache.

- **Web interface:** Responsive dashboard at `http://dashboard-ip:5000` with network topology visualization.## Project summary

- **Real-time updates:** WebSocket connections for live device status and scan progress.

- **Data synchronization:** Git hooks and REST API sync data from scanner to dashboard.- **Goal:** Map your network, keep it current, highlight service changes, log everything in Git for full auditability, and provide a modern web interface for monitoring and management.

- **Mobile support:** Responsive design works on phones/tablets for on-the-go monitoring.- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), Flask/Python web dashboard, SQLite (dashboard cache), WebSocket (real-time updates), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).

- **Network topology:** Interactive graph showing device relationships and network segments.- **Outputs:** Per-scan Markdown summaries, per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, quick block commands, and a responsive web dashboard with network topology visualization.

- **Vulnerability timeline:** Visual timeline of discovered vulnerabilities with severity indicators.- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices; real-time dashboard updates via WebSocket. self-hosted system to discover devices, fingerprint OS/services, detect vulnerabilities, track changes over time with Git, and provide actionable “block” commands—ready for Obsidian later but not required now.

- **Device management:** Quick access to block commands and device details from web interface.

Link to the Step-by-step section (header link): [[#action-plan-for-self-hosted-network-mapping-and-change-tracking|Action Plan for Self-hosted network mapping and change tracking]]

### Data Flow

---

1. **Scanner LXC** → Git commits → Git hook triggers dashboard sync

2. **Dashboard LXC** → Pulls Git changes → Updates SQLite cache → Broadcasts WebSocket updates## Project summary

3. **Web clients** → Receive real-time updates → Display network status and changes

- **Goal:** Map your network, keep it current, highlight service changes, and log everything in Git for full auditability.

---- **Stack:** Nmap (discovery, fingerprinting, vuln), ndiff (deltas), Git (history), optional ntfy/email (alerts), optional arpwatch (real-time MAC sightings).

- **Outputs:** Per-scan Markdown summaries and per-host Markdown pages with MAC/vendor, OS/services, vulnerability notes, service-change highlights, and quick block commands.

## Scripts- **Automation:** Daily discovery; weekly fingerprint; monthly vulnerability scan; Git commits every run; alerts for new devices

[[install_nmap_fingplus.sh]]---

[[nmap_fingplus_git.sh]]## Architecture and components

[[install_dashboard.sh]]

[[dashboard_app.py]]- **Nmap LXC host:** Runs scans and produces Markdown registry and diffs.

[[sync_dashboard.sh]]- **Git repo:** Lives at `/nmap/registry`; every run commits changes with timestamped messages.

- **Scan outputs:** Normal + XML in `/nmap/scans` for discovery, fingerprint, and vuln.
- **Diff outputs:** `ndiff` results in `/nmap/diffs` and embedded in the daily summary.
- **Alerts (optional):** ntfy or email notifications for newly detected devices.
- **Actionability:** Per-host “Quick Block Commands” for fast isolation via iptables/ebtables.

---

## Scripts

[[install_nmap_fingplus.sh]]
[[nmap_fingplus_git.sh]]
