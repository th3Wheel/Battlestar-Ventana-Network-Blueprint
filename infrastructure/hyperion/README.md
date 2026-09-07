## Hyperion infrastructure

This directory is reserved for the Hyperion ambient-lighting service and its
deployment configuration.

Current contents:

- `device-wled-ws2815.json` — WLED device descriptor for the six-segment room
  wash.

Deployment files are intentionally not defined yet. Future additions may
include a pinned Hyperion container definition, service-specific configuration,
health checks, and documented network-policy requirements.

The WLED device descriptor is configuration data only; it is not a runnable
Hyperion deployment.
