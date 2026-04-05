# Thingino Deterministic Provisioning

This section contains the reproducible provisioning system for Thingino-based Cinnado D1 cameras.

## Structure

- templates/thingino.conf.template  
- templates/camera-map.yaml  
- scripts/generate-configs.sh  
- cameras/ (generated output)

## Workflow

1. Edit camera-map.yaml  
2. Run generate-configs.sh  
3. Copy each generated thingino.conf to SD card root  
4. Boot camera to auto‑provision

## Provisioning Flow

```mermaid
flowchart TD

A[Flash SD with Thingino installer] --> B[Place thingino.conf on SD root]
B --> C[Insert SD into camera]
C --> D[Boot camera]
D --> E{Config file detected?}

E -- Yes --> F[Import network settings]
F --> G[Join IoT VLAN Wi-Fi]
G --> H[Camera reachable at static IP]
H --> L[Provision complete]

E -- No --> I[Fallback: Camera starts AP mode]
I --> J[Manual provisioning via web UI]
J --> L[Provision complete]
