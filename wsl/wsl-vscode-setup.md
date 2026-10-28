# WSL + VS Code Setup Guide

## Canonical `.wslconfig` (Tuned for Your Hardware)

```ini
    [wsl2]
    memory=12GB
    processors=2
    swap=0
    localhostForwarding=true
    nestedVirtualization=true
    dnsTunneling=true
    networkingMode=mirrored
    [experimental]
    autoMemoryReclaim=gradual
```

## Canonical `/etc/wsl.conf`

```ini
    [boot]
    systemd=true

    [network]
    generateResolvConf=true

    [interop]
    enabled=true
    appendWindowsPath=false

    [automount]
    enabled=true
    mountFsTab=true
    options="metadata,umask=22,fmask=11"
```

## VS Code + WSL Architecture Diagram (Mermaid)

```mermaid

    flowchart TD
        A[Windows 11 Host] --> B[WSL2 Kernel]
        B --> C[Ubuntu Filesystem]
        C --> D[VS Code Server (WSL Extension Host)]
        A --> E[VS Code Client (Windows)]
        E <--> D
        D --> F[GitHub Copilot (WSL Extension)]
        D --> G[Claude Code (WSL Extension)]
        C --> H[Dev Tools: Git, Python, Node, Docker CLI]
        A --> I[Docker Desktop (WSL Backend)]
        I <--> C

```

## Complete Reproducible Setup Script (Package‑Manager‑Only)

### Windows-side (PowerShell)

```powershell

    wsl --install
    wsl --shutdown

    # Create .wslconfig
    $config = @"
    [wsl2]
    memory=12GB
    processors=2
    swap=0
    localhostForwarding=true
    nestedVirtualization=true
    dnsTunneling=true
    networkingMode=mirrored
    [experimental]
    autoMemoryReclaim=gradual
"@
    Set-Content -Path "$env:USERPROFILE\.wslconfig" -Value $config
```

### WSL-side (Ubuntu)

```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y build-essential git curl zsh starship

    # Enable systemd
    sudo bash -c 'cat <<EOF > /etc/wsl.conf
    [boot]
    systemd=true

    [network]
    generateResolvConf=true

    [interop]
    enabled=true
    appendWindowsPath=false

    [automount]
    enabled=true
    mountFsTab=true
    options="metadata,umask=22,fmask=11"
EOF'

    # Enable Starship in Zsh
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc

    # Optional: Docker Desktop integration
    # Install Docker Desktop on Windows and enable Ubuntu under Settings >
    # Resources > WSL Integration, then check access:
    docker version
```

### Restart WSL

From Windows PowerShell, run `wsl --shutdown`, then reopen Ubuntu before
continuing. The `/etc/wsl.conf` settings are applied when the distribution
starts.

### VS Code-side

1. Install extensions:
   - Remote - WSL
   - GitHub Copilot
   - Claude Code

2. From Windows PowerShell, open your project inside WSL:

   ```powershell
   code --remote wsl+Ubuntu /home/your-ubuntu-username/your-project
   ```

3. Confirm extensions show under **WSL: Ubuntu**.
