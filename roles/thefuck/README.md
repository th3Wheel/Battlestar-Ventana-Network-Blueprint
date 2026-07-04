# thefuck role

Installs and configures [`nvbn/thefuck`](https://github.com/nvbn/thefuck) for interactive admin shells.

## Purpose

- Install `thefuck` on Linux and Windows targets.
- Configure guarded shell/profile initialization so startup is safe when `thefuck` is not on `PATH`.

## Variables

- `thefuck_alias` (default: `fuck`)
- `thefuck_shells` (default: `bash`, `zsh`)
- `thefuck_install_for_root` (default: `false`)

## Supported platforms

- Linux (Bash and optional Zsh profile integration)
- Windows (PowerShell Core and Windows PowerShell 5.1 profile integration)

## Usage

```yaml
- name: Install and configure thefuck on all supported hosts
  hosts: thefuck_hosts
  become: false
  roles:
    - role: ../../roles/thefuck
      tags: [thefuck]
```
