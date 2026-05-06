---
name: thingino-automation
description: "Guidance for Thingino camera automation and SD-card provisioning. Use when asked to configure runonce.sh or run.sh, automate firmware updates from SD card, manage runonce.done behavior, apply settings with jct, use uEnv.txt bootloader parameters, or execute full SSH-based reconfiguration after a firmware upgrade."
argument-hint: "Describe the Thingino automation or runonce workflow you want to build, verify, or troubleshoot"
---

# Thingino Automation Skill

Use this skill to implement and troubleshoot Thingino automation patterns based on SD-card scripts, firmware auto-update files, and runonce-driven camera provisioning.

## When to Use This Skill

- Configure camera settings with `runonce.sh` after a full update.
- Automate repeated actions at boot with `run.sh`.
- Apply firmware updates from an SD card using Thingino auto-update naming.
- Troubleshoot why `runonce.sh` or `run.sh` did not execute.
- Reconfigure Wi-Fi and JSON-backed settings without portal/Web UI steps.
- Build a repeatable SSH + `sysupgrade -x` workflow for offline upgrades.

## Reference Index

| Topic                                                        | Load when                                                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| [Automation Overview](./references/automation-overview.md)   | You need SD automation primitives, stop-file behavior, `uEnv.txt`, or provisioning options. |
| [Runonce Workflow](./references/runonce-workflow.md)         | You need one-time Wi-Fi and JSON configuration logic with `wlan` and `jct`.                 |
| [Full Upgrade via SSH](./references/full-upgrade-via-ssh.md) | You need end-to-end upgrade and post-upgrade reprovisioning steps.                          |
| [Troubleshooting](./references/troubleshooting.md)           | A script did not execute or settings did not apply as expected.                             |

## Routing Guide

- "create runonce" or "configure camera from SD" -> load [Runonce Workflow](./references/runonce-workflow.md)
- "auto update firmware from SD" -> load [Automation Overview](./references/automation-overview.md)
- "upgrade from SSH" or "offline sysupgrade" -> load [Full Upgrade via SSH](./references/full-upgrade-via-ssh.md)
- "why did runonce not run" -> load [Troubleshooting](./references/troubleshooting.md)

## Core Constraints

- `run.sh` executes on every boot while present on the SD card.
- `runonce.sh` executes once, then Thingino creates `runonce.done` to block repeated runs.
- Delete `runonce.done` before reboot when you intentionally need `runonce.sh` to run again.
- For SD firmware auto-flash, use exact filenames:
  - `autoupdate-full.bin` for full firmware image
  - `autoupdate-uboot.bin` for bootloader-only image
- Wi-Fi provisioning through `uEnv.txt` is deprecated in recent 2026 builds; prefer `run.sh` or `runonce.sh`.

## Safe Workflow Policy

- Validate target firmware is correct for the camera hardware before flashing.
- Avoid embedding real credentials in committed scripts. Use placeholders for SSID/password in examples.
- Confirm applied settings with `jct ... print` after import operations.
- Keep one camera as a canary before fleet-wide rollout.

## References

- [Thingino Wiki - Automation](https://github.com/themactep/thingino-firmware/wiki/Automation)
- [Thingino Wiki - Configuring camera using runonce.sh script](https://github.com/themactep/thingino-firmware/wiki/Configuring-camera-using-runonce.sh-script)
