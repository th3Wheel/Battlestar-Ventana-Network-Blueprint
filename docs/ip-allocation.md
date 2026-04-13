# Deterministic IP Allocation Table for Thingino Cameras

This table serves as the authoritative reference for IP address assignments to Thingino-based Cinnado D1 cameras. Each camera is assigned a unique static IP address within the specified range, ensuring consistent network configuration and easy identification.

| Camera ID | Hostname   | IP Address  | VLAN     | Notes            |
| --------- | ---------- | ----------- | -------- | ---------------- |
| 001       | cam-d1-001 | 10.10.20.51 | IoT (20) | Primary entryway |
| 002       | cam-d1-002 | 10.10.20.52 | IoT (20) | Garage           |
| 003       | cam-d1-003 | 10.10.20.53 | IoT (20) | Backyard         |

## Allocation Rules

| Rule       | Value                   |
| ---------- | ----------------------- |
| Static IPs | 10.10.20.50–10.10.20.99 |
| Hostnames  | cam-d1-###              |
| VLAN       | 20 = IoT network        |
