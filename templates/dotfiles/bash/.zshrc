# ── Battlestar Ventana — Zsh dotfile ─────────────────────────────────────────
# Deployed by: bash scripts/deploy-dotfiles.sh
# Source:      templates/dotfiles/bash/.zshrc

# ── PATH: ensure ~/.local/bin is included (pip --user installs here) ──────────
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ── thefuck ───────────────────────────────────────────────────────────────────
# https://github.com/nvbn/thefuck  |  install: pip3 install thefuck --user
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias fuck)"
fi
# ─────────────────────────────────────────────────────────────────────────────
