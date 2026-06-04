#!/usr/bin/env bash

set -euo pipefail

PATH_BLOCK=$'if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then\n    export PATH="$HOME/.local/bin:$PATH"\nfi'
THEFUCK_BLOCK=$'if command -v thefuck &>/dev/null; then\n    eval "$(thefuck --alias fuck)"\nfi'

ensure_python_tooling() {
    if command -v apt-get &>/dev/null; then
        echo "apt-get detected. Ensuring python prerequisites are installed..."
        if command -v sudo &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y python3-dev python3-pip python3-setuptools
        else
            apt-get update
            apt-get install -y python3-dev python3-pip python3-setuptools
        fi
    fi

    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 is required but was not found in PATH." >&2
        exit 1
    fi

    if ! command -v pip3 &>/dev/null; then
        echo "Error: pip3 is required but was not found in PATH." >&2
        exit 1
    fi
}

append_block_if_missing() {
    local file="$1"
    local needle="$2"
    local block="$3"

    [[ -f "$file" ]] || touch "$file"

    if grep -Fq "$needle" "$file"; then
        echo "Already configured in $file: $needle"
        return
    fi

    printf '\n%s\n' "$block" >>"$file"
    echo "Updated $file"
}

ensure_python_tooling

echo "Installing thefuck (user scope)..."
pip3 install thefuck --user

append_block_if_missing "$HOME/.bashrc" '$HOME/.local/bin' "$PATH_BLOCK"
append_block_if_missing "$HOME/.bashrc" 'thefuck --alias' "$THEFUCK_BLOCK"

if [[ -f "$HOME/.zshrc" ]]; then
    append_block_if_missing "$HOME/.zshrc" '$HOME/.local/bin' "$PATH_BLOCK"
    append_block_if_missing "$HOME/.zshrc" 'thefuck --alias' "$THEFUCK_BLOCK"
fi

echo
echo "thefuck bootstrap complete."
echo "Reload your shell or run: source ~/.bashrc"
if [[ -f "$HOME/.zshrc" ]]; then
    echo "For zsh, run: source ~/.zshrc"
fi
