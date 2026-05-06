# Automation Overview

## What Thingino Can Automate from a microSD Card

Thingino supports microSD card-driven automation for firmware updates, bootloader environment changes, and boot-time script execution.

## Firmware Auto-Update via microSD Card

- Copy firmware image to microSD card root and rename to `autoupdate-full.bin`.
- Reboot with microSD card inserted. Bootloader flashes this image during boot.
- On success, Thingino creates `autoupdate-full.done` to prevent repeated reflashing.
- Remove `autoupdate-full.done` before reusing the same card for another camera.

For bootloader-only updates:

- Rename bootloader image to `autoupdate-uboot.bin`.
- Use the same insert-and-reboot flow.

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
