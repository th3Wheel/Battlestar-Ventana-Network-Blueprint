# Automation Overview

## What Thingino Can Automate from a microSD Card

Thingino supports microSD card-driven automation for firmware updates, bootloader environment changes, and boot-time script execution.

## Getting or Creating a Firmware Image

Before flashing, obtain the correct image for your specific camera model.

**Download a pre-built image:**

1. Visit [https://thingino.com/](https://thingino.com/) and locate your camera model.
2. Download the latest full firmware `.bin` file.
3. Verify the file matches your SoC and hardware revision — flashing a mismatched image can brick the device.

**Full upgrade vs. partial update:**

| Type | File / Flag | What changes | U-Boot environment |
|---|---|---|---|
| Full upgrade | `autoupdate-full.bin` / `sysupgrade -f` | Bootloader + kernel + userland | Reset (Wi-Fi, root password lost) |
| Partial update | `sysupgrade -p` | Kernel + userland only | Preserved |

Full upgrade followed by provisioning is the recommended approach for reproducible, clean deployments. Partial updates are convenient for routine patches when the existing config is known-good.

**Self-compiled builds:**

If building from source, use `make` in the [thingino-firmware](https://github.com/themactep/thingino-firmware) repository. Self-compiled builds support DHCP option 160 provisioning auto-discovery — see the [Provisioning wiki](https://github.com/themactep/thingino-firmware/wiki/Provisioning).

## Firmware Auto-Update via microSD Card

- Copy firmware image to microSD card root and rename to `autoupdate-full.bin`.
- Reboot with microSD card inserted. Bootloader flashes this image during boot.
- On success, Thingino creates `autoupdate-full.done` to prevent repeated reflashing.
- Remove `autoupdate-full.done` before reusing the same card for another camera.

For bootloader-only updates:

- Rename bootloader image to `autoupdate-uboot.bin`.
- Use the same insert-and-reboot flow.

## Firmware Upgrade via SSH (sysupgrade)

When the camera is already running and reachable over SSH, use the built-in `sysupgrade` command.

**Partial upgrade (recommended for routine updates):**

```sh
sysupgrade -p
```

Fetches the latest partial build from GitHub and preserves the U-Boot environment (Wi-Fi SSID, root password, etc.).

**Full upgrade:**

```sh
sysupgrade -f
```

Replaces the entire system including the bootloader. U-Boot environment is reset — reconfigure Wi-Fi and credentials after boot.

**Upgrade from a local file or URL:**

```sh
sysupgrade /path/to/firmware.bin
sysupgrade https://example.com/firmware.bin
```

**Pin a specific release date:**

```sh
sysupgrade -f -d 2025-12-01
```

**Install a specific date's build** (requires `-f` or `-p`).

Note: After a full upgrade the camera may take up to 60 seconds to complete provisioning before it is ready for use.

## Bootloader Environment with uEnv.txt

Create `uEnv.txt` in microSD card root with key/value pairs:

```text
parameter1=value
parameter2=multiword value
parameter3='complex value using %{variable} data'
parameter4=
```

Behavior:

- Insert microSD card and reboot to import values.
- Existing values are updated or added.
- Keys with empty assignment are unset.

Important note:

- Wi-Fi setup through `uEnv.txt` is deprecated in recent 2026 firmware builds.
- Use `run.sh` or `runonce.sh` for Wi-Fi provisioning.

## Boot Scripts from microSD Card

Thingino recognizes two script filenames in microSD card root:

- `run.sh`: executed on every boot while present.
- `runonce.sh`: executed once, then `runonce.done` is created.

If you need `runonce.sh` to execute again:

- Delete `runonce.done`.
- Reboot.

## Additional Automation Paths

- Ansible-based automation can be layered on top of camera SSH management.
- DHCP option 160 configuration auto-discovery is available for self-compiled builds.

## Source

- [Thingino Wiki - Automation](https://github.com/themactep/thingino-firmware/wiki/Automation)
- [Thingino Wiki - Updating Firmware](https://github.com/themactep/thingino-firmware/wiki/Updating-Firmware)
- [Thingino Wiki - Provisioning](https://github.com/themactep/thingino-firmware/wiki/Provisioning)
