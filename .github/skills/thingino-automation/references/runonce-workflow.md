# Runonce Workflow

## Purpose

Use `runonce.sh` to restore Wi-Fi and camera settings automatically after a full update, without manual Web UI portal steps.

## Prerequisites

- microSD card formatted as FAT32.
- `runonce.sh` placed in microSD card root.
- `runonce.done` absent when you want execution on next boot.

## Typical Flow

1. Configure Wi-Fi with `wlan configure <SSID> <PASSWORD>`.
2. Generate temporary JSON files in `/tmp`.
3. Import those JSON fragments into target config files using `jct ... import`.
4. Set timezone using `tzselect -n <RegionOrCity>`.
5. Reboot to apply runtime-dependent changes.

## Example Skeleton

```bash
wlan configure YOUR_SSID YOUR_PASSWORD

echo '{"stream0":{"fps":15,"gop":15},"stream1":{"fps":5,"gop":5}}' > /tmp/myprudynt.json
jct /etc/prudynt.json import /tmp/myprudynt.json

echo '{"webui":{"paranoid":true}}' > /tmp/mythingino.json
jct /etc/thingino.json import /tmp/mythingino.json

tzselect -n Chicago
reboot
```

## Validation Commands

Inspect effective config after boot:

```bash
jct /etc/prudynt.json print
jct /etc/thingino.json print
```

Use exports to capture baseline or changed keys for future templates:

```bash
jct /etc/prudynt.json export
jct /etc/thingino.json export
```

## Operational Notes

- SSID and password matching is case-sensitive.
- `runonce.sh` is intended for one-time provisioning; reruns require deleting `runonce.done`.
- Keep JSON snippets minimal to avoid unintended broad merges.

## Source

- [Thingino Wiki - Configuring camera using runonce.sh script](https://github.com/themactep/thingino-firmware/wiki/Configuring-camera-using-runonce.sh-script)
- [Thingino Wiki - Automation](https://github.com/themactep/thingino-firmware/wiki/Automation)
