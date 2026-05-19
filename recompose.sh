#!/bin/bash

# Script to convert safe.env to .env using 1Password CLI and run docker compose

set -e  # Exit on any error

# Check if safe.env exists
if [ ! -f "safe.env" ]; then
    echo "Error: safe.env file not found in current directory"
    exit 1
fi

# Check if op (1Password CLI) is available
if ! command -v op &> /dev/null; then
    echo "Error: 1Password CLI (op) is not installed or not in PATH"
    exit 1
fi

# Check if user is logged in to 1Password
if ! op whoami &> /dev/null; then
    echo "Error: Not logged in to 1Password. Please run 'op signin' first"
    exit 1
fi

# Clear/create .env file
> .env

echo "Converting safe.env to .env using 1Password CLI..."

# Read safe.env line by line
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    
    # Remove any trailing whitespace from key
    key=$(echo "$key" | sed 's/[[:space:]]*$//')
    
    if [[ "$value" == op://* ]]; then
        echo "Fetching secret for $key..."
        actual_value=$(op read "$value")
        if [ $? -ne 0 ]; then
            echo "Error: Failed to read secret for $key from 1Password"
            exit 1
        fi
        echo "$key=$actual_value" >> .env
    else
        echo "$key=$value" >> .env
    fi
done < safe.env

echo "Successfully created .env file"

# Check if docker-compose.yml or docker-compose.yaml exists
compose_file=""
if [ -f "docker-compose.yml" ]; then
    compose_file="docker-compose.yml"
elif [ -f "docker-compose.yaml" ]; then
    compose_file="docker-compose.yaml"
else
    echo "Error: No docker-compose.yml or docker-compose.yaml found in current directory"
    exit 1
fi

echo "Running docker compose with $compose_file..."
docker compose up