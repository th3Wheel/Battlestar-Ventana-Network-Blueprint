# Ansible

Playbooks and roles for evaluating the router designs (Linux router, OpenWrt in Docker, OPNsense VM) against the
VLAN catalogue, plus a few host-setup playbooks. Run them from the execution environment image below so the
controller is the same everywhere.

## Execution environment image

`Containerfile` builds a controller image: Python 3.13, `ansible-core` 2.21, the collections in
`collections/requirements.yml`, the Python libraries in `requirements.txt`, `git` and an SSH client. It runs as the
unprivileged user `runner` (UID 1000).

Build it from this directory:

```bash
docker build -t battlestar-ventana-ee -f Containerfile .
```

The image contains tools only. Mount the repository at `/workspace`; the working directory is `/workspace/ansible`
and `ANSIBLE_CONFIG` already points at `ansible/ansible.cfg`, so `ansible.cfg`, the inventory and the roles are
found without extra flags:

```bash
docker run --rm -v "$PWD/..:/workspace" battlestar-ventana-ee \
  ansible-playbook playbooks/evaluate-linux-router.yml --syntax-check
```

Playbooks write their output under `projects/` in the mounted repository (for example
`projects/route-pi-squared/infrastructure/linux-router/prototypes/`), so it appears on your side of the mount.

### Reaching the hosts

The inventory uses SSH with `host_key_checking = True`. The image has an empty `/home/runner/.ssh` (mode 0700) for
this:

- Mount a directory holding `known_hosts` and a private key at `/home/runner/.ssh`. SSH refuses a private key that
  other users can read, and bind mounts from Windows and macOS hosts show every file as readable by all, so copy the
  key into a Docker volume with mode 0600 instead of bind-mounting your own `~/.ssh`.
- Or forward an agent: mount the agent socket and pass `SSH_AUTH_SOCK`.

API tasks (`ansible.builtin.uri`) talk to the hosts directly and ignore `-c local`. For example the OPNsense
`generate-config` play issues a request to the OPNsense API address; run it only when that VM is the intended target.

### What was checked

The image was built from these files and run as `runner` with the repository mounted:

- `ansible --version` finds `ansible/ansible.cfg`; the four required collections are readable by `runner`.
- All five playbooks pass `ansible-playbook --syntax-check`, and `ansible-inventory --graph` parses.
- The generated launcher scripts ran against every generated `.env` file with `ip`, `lnxrouter` and `qm` replaced by
  stubs. Nothing was run against a router, Proxmox host or OPNsense VM.

## Known limitation: VLAN data is not loaded by `ansible-playbook`

The roles loop over `vlans`, defined in `group_vars/all/vlan-vars.yml`. `ansible-playbook` loads `group_vars` only
from next to the inventory or next to the playbook, and this directory is neither, so a run of `evaluate-linux-router.yml`
fails at the first task that uses `vlans` ("`vlans` is undefined"). Passing the file explicitly works:

```bash
ansible-playbook playbooks/evaluate-linux-router.yml -e @group_vars/all/vlan-vars.yml --tags generate-config
```

Moving `group_vars/` to `inventory/group_vars/` fixes it permanently but changes the documented path of the VLAN
source of truth, which several documents name.
