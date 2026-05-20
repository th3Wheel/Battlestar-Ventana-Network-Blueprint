#!/bin/bash

# Script to install 1Password CLI and configure it for repository connection
# This sets up 1Password Connect Server credentials for the repository

set -e  # Exit on any error
a
echo "Installing 1Password CLI..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (assuming Debian/Ubuntu)
    echo "Detected Linux. Installing via apt..."
    
    # Add 1Password repository
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    
    sudo apt update
    sudo apt install -y 1password-cli
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Detected macOS. Installing via Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    
    brew install --cask 1password/tap/1password-cli
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash/MSYS)
    echo "Detected Windows. Installing via winget or scoop..."
    
    if command -v winget &> /dev/null; then
        winget install --id 1Password.1Password-CLI --accept-source-agreements --accept-package-agreements
    elif command -v scoop &> /dev/null; then
        scoop bucket add extras
        scoop install 1password-cli
    else
        echo "Error: Neither winget nor scoop found. Please install 1Password CLI manually from https://developer.1password.com/docs/cli/"
        exit 1
    fi
    
else
    echo "Error: Unsupported OS: $OSTYPE"
    echo "Please install 1Password CLI manually from https://developer.1password.com/docs/cli/"
    exit 1
fi

echo "1Password CLI installed successfully."

# Verify installation
if ! command -v op &> /dev/null; then
    echo "Error: 1Password CLI installation failed."
    exit 1
fi

echo "Configuring 1Password CLI for repository connection..."

# Check for service account token
if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
    echo "Using service account token for authentication..."
    export OP_SERVICE_ACCOUNT_TOKEN
else
    echo "No service account token found. Please sign in interactively..."
    echo "Note: For automated setups, set OP_SERVICE_ACCOUNT_TOKEN environment variable"
    op signin
fi

# Verify authentication
if ! op whoami &> /dev/null; then
    echo "Error: Failed to authenticate with 1Password."
    exit 1
fi

echo "Authentication successful."

# Create Connect Server credentials
echo "Creating 1Password Connect Server credentials..."
op connect server create "Battlestar-Ventana-Connect" --vaults "Private" > 1password-credentials.json

if [ $? -ne 0 ]; then
    echo "Error: Failed to create Connect Server credentials."
    exit 1
fi

echo "Connect Server credentials created successfully: 1password-credentials.json"
echo ""
echo "Next steps:"
echo "1. Deploy 1Password Connect using the generated credentials (see infrastructure/1password/connectserver.md)"
echo "2. Use the credentials in your docker-compose.yml or other configurations"
echo "3. Issue scoped tokens for your services (XPipe, Ansible, etc.)"
echo ""
echo "Repository is now configured for 1Password Connect!"