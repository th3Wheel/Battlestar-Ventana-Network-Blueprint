# PowerShell script to convert safe.env to .env using 1Password CLI and run docker compose

param()

# Check if safe.env exists
if (-not (Test-Path "safe.env")) {
    Write-Error "Error: safe.env file not found in current directory"
    exit 1
}

# Check if op (1Password CLI) is available
if (-not (Get-Command op -ErrorAction SilentlyContinue)) {
    Write-Error "Error: 1Password CLI (op) is not installed or not in PATH"
    exit 1
}

# Check if user is logged in to 1Password
try {
    $null = op whoami
} catch {
    Write-Error "Error: Not logged in to 1Password. Please run 'op signin' first"
    exit 1
}

# Clear/create .env file
New-Item -ItemType File -Path ".env" -Force | Out-Null

Write-Host "Converting safe.env to .env using 1Password CLI..."

# Read safe.env line by line
Get-Content "safe.env" | ForEach-Object {
    $line = $_.Trim()
    
    # Skip empty lines and comments
    if ([string]::IsNullOrEmpty($line) -or $line.StartsWith("#")) {
        return
    }
    
    # Split on first '='
    $parts = $line -split '=', 2
    if ($parts.Length -ne 2) {
        # If no '=', treat as key with empty value
        $key = $line
        $value = ""
    } else {
        $key = $parts[0].Trim()
        $value = $parts[1]
    }
    
    if ($value -like "op://*") {
        Write-Host "Fetching secret for $key..."
        try {
            $actual_value = op read $value
            "$key=$actual_value" | Out-File -FilePath ".env" -Append -Encoding UTF8
        } catch {
            Write-Error "Error: Failed to read secret for $key from 1Password"
            exit 1
        }
    } else {
        "$key=$value" | Out-File -FilePath ".env" -Append -Encoding UTF8
    }
}

Write-Host "Successfully created .env file"

# Check if docker-compose.yml or docker-compose.yaml exists
$compose_file = ""
if (Test-Path "docker-compose.yml") {
    $compose_file = "docker-compose.yml"
} elseif (Test-Path "docker-compose.yaml") {
    $compose_file = "docker-compose.yaml"
} else {
    Write-Error "Error: No docker-compose.yml or docker-compose.yaml found in current directory"
    exit 1
}

Write-Host "Running docker compose with $compose_file..."
docker compose up