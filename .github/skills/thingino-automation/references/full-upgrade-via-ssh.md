# Full Upgrade via SSH

## Goal

Perform a full Thingino firmware update from SSH and automatically restore configuration via `runonce.sh` on first boot.

## Preconditions

- Correct firmware file for target camera hardware.
- SD card inserted with prepared `runonce.sh`.
- `runonce.done` removed before upgrade reboot.
- SSH access to camera.

## Procedure

1. Copy firmware to camera `/tmp`:

```bash
scp -O /path/to/firmware_filename.bin root@CAMERA_IP:/tmp/
```

1. Connect to camera:

```bash
ssh root@CAMERA_IP
```

1. Remove stop file so `runonce.sh` executes after upgrade:

```bash
rm /mnt/mmcblk0p1/runonce.done
```

1. Run full upgrade in offline mode when internet is unavailable:

```bash
sysupgrade -x /tmp/firmware_filename.bin
```

1. Wait for reboot. On boot, `runonce.sh` should run and create `runonce.done`.
1. SSH again and set root password (default initial password is `root` if prompted).

## Post-Upgrade Verification

- Confirm camera joins Wi-Fi as expected.
- Verify key settings with `jct ... print`.
- Confirm `runonce.done` exists after successful first-run execution.

## Guardrails

- Do not reuse firmware blindly across camera models.
- Keep one known-good SD image and one known-good firmware artifact for rollback planning.
- Test on one camera before updating a larger group.

## Source

- [Thingino Wiki - Configuring camera using runonce.sh script](https://github.com/themactep/thingino-firmware/wiki/Configuring-camera-using-runonce.sh-script)
