# Troubleshooting

| Symptom                                       | Likely Cause                            | Recommended Action                                                                                          |
| --------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `runonce.sh` did not run after reboot         | `runonce.done` still exists             | Delete `runonce.done` from microSD card mount and reboot again.                                                       |
| `run.sh` did not run                          | File missing or wrong filename/location | Ensure script is named exactly `run.sh` in microSD card root and is readable.                                         |
| Camera did not join Wi-Fi                     | SSID/password typo or case mismatch     | Re-check `wlan configure` values; SSID and password are case-sensitive.                                     |
| Imported settings appear unchanged            | JSON merge targeted wrong file/path     | Re-run with correct `jct /etc/<file>.json import /tmp/<fragment>.json`, then validate with `jct ... print`. |
| Reflash loops unexpectedly                    | Stop file missing on reused microSD card     | Confirm `autoupdate-full.done` exists after successful flash; restore or remove update image.               |
| `runonce.sh` reconfiguration does not persist | Script failed before completing imports | Add incremental checks and inspect values with `jct ... print` after each import.                           |

## Quick Checks

```bash
ls -la /mnt/mmcblk0p1
jct /etc/prudynt.json print
jct /etc/thingino.json print
```

## Source

- [Thingino Wiki - Automation](https://github.com/themactep/thingino-firmware/wiki/Automation)
- [Thingino Wiki - Configuring camera using runonce.sh script](https://github.com/themactep/thingino-firmware/wiki/Configuring-camera-using-runonce.sh-script)
