## 1Password Connect for Battlestar secrets

Combined How-to + Explanation for deploying 1Password Connect and consuming it from XPipe, Ansible, and other services in this repo. Emphasis: least privilege, no plain environment variables for secrets, and per-service tokens with rotation.

### What you’ll achieve

- Deploy 1Password Connect (Docker Compose primary; Kubernetes/Helm and Portainer notes).
- Issue scoped tokens and store them securely (no plain env vars).
- Use those tokens from XPipe (MCP automation + pre-connection hook), Ansible, and other services.
- Validate and harden (TLS, rotation, audit).

### Prereqs & assumptions

- Network placement: internal-only; default API port 8080. Do not expose to the Internet.
- Files: `1password-credentials.json` from `op connect server create`.
- Tools: Docker/Compose; optional kubectl/Helm; Portainer if you prefer stacks.
- Secrets handling: tokens live in Kubernetes Secrets or root-owned files with `0600`. Avoid long-lived plain env vars; use env only as short-lived, in-memory export during tests.

### Quick architecture (why Connect)

- Two components: `connect-api` (serves REST) and `connect-sync` (pulls from 1Password cloud to local state).
- Tokens are scoped; issue one per consumer (XPipe, Ansible, app). Minimal vault/item access per token.
- Traffic stays inside LAN; use TLS for east-west where possible.

### Deploy Connect (primary: Docker Compose)

1) Create `docker-compose.yaml` with `1password/connect-api` and `1password/connect-sync`.
2) Mount `1password-credentials.json` read-only at `/home/opuser/.op/1password-credentials.json` for both containers.
3) Bind port `8080` to an internal interface only (or behind an internal LB/reverse proxy with TLS).
4) Start: `docker compose up -d`.
5) Smoke test: `curl http://<connect-host>:8080/health` → expect status ok.

**Complete docker-compose.yaml example:**

```yaml
version: "3.8"

services:
  connect-api:
    image: 1password/connect-api:latest
    container_name: op-connect-api
    restart: unless-stopped
    ports:
      # Bind to internal interface only; replace 10.76.50.10 with your ServerVault IP
      - "10.76.50.10:8080:8080"
    volumes:
      - ./1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro
      - connect-api-data:/home/opuser/.op/data
    environment:
      - OP_SESSION_inactivity_timeout=30m
      - OP_LOG_LEVEL=info
    networks:
      - op-connect
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  connect-sync:
    image: 1password/connect-sync:latest
    container_name: op-connect-sync
    restart: unless-stopped
    volumes:
      - ./1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro
      - connect-sync-data:/home/opuser/.op/data
    environment:
      - OP_LOG_LEVEL=info
    networks:
      - op-connect
    depends_on:
      connect-api:
        condition: service_healthy

volumes:
  connect-api-data:
  connect-sync-data:

networks:
  op-connect:
    driver: bridge
```

**Deployment steps:**

```bash
# 1. Place 1password-credentials.json in the same directory as docker-compose.yaml
ls -lh 1password-credentials.json  # Verify file exists and has restricted perms

# 2. Start the services
docker compose up -d

# 3. Verify both containers are running
docker compose ps

# 4. Check logs for any errors
docker compose logs -f

# 5. Test health endpoint
curl http://10.76.50.10:8080/health
# Expected: {"name":"1Password Connect API","version":"...","dependencies":[...]}
```

### Optional: Kubernetes/Helm or Portainer

- Helm chart: provide the credentials file as a secret, set service type ClusterIP, and store tokens in a Secret. Keep ingress internal; add TLS if terminating at the proxy.
- Portainer: deploy the same compose stack; ensure network is internal-only and mount the credentials file with read-only perms.

### Create and handle tokens (no plain env vars)

- Create per-service tokens: `op connect token create <name> --server <server> --vault <vault>`.
- Storage: Kubernetes Secret (recommended) or root-owned file `0600` on hosts (e.g., `/etc/op/connect/<consumer>.token`).
- Usage: load tokens from file or secret mount at runtime; avoid persistent env vars. If a command needs env, export from a protected file and unset immediately after use.
- Rotation: issue short-lived tokens per service; rotate on a regular cadence (e.g., 30–90 days) or on suspicion; revoke unused tokens; log usage.

**Token creation examples:**

```bash
# 1. Create Connect server and generate credentials (one-time setup)
op connect server create battlestar-connect \
  --vault "Battlestar Secrets" \
  --format json > 1password-credentials.json

# 2. Verify credentials file was created
ls -lh 1password-credentials.json
chmod 600 1password-credentials.json

# 3. Create scoped token for XPipe
op connect token create xpipe-battlestar \
  --server battlestar-connect \
  --vault "Battlestar Secrets"
# Save this token securely; it will only be shown once

# 4. Create scoped token for Ansible automation
op connect token create ansible-automation \
  --server battlestar-connect \
  --vault "Battlestar Secrets"

# 5. Create scoped token for a specific service (e.g., Pi-hole deployment)
op connect token create pihole-deployment \
  --server battlestar-connect \
  --vault "ServerVault Services"
```

**Secure token storage on host:**

```bash
# Create token directory with restricted permissions
sudo mkdir -p /etc/op/connect
sudo chmod 700 /etc/op/connect

# Store XPipe token (paste token when prompted)
sudo tee /etc/op/connect/xpipe.token > /dev/null
sudo chmod 600 /etc/op/connect/xpipe.token
sudo chown root:root /etc/op/connect/xpipe.token

# Verify permissions
ls -la /etc/op/connect/
# Expected: drwx------ root root ... connect
#           -rw------- root root ... xpipe.token
```

**Testing token scope:**

```bash
# Load token from secure file
export OP_API_TOKEN=$(sudo cat /etc/op/connect/xpipe.token)

# List accessible vaults (should only show authorized vaults)
curl -s -H "Authorization: Bearer $OP_API_TOKEN" \
  http://10.76.50.10:8080/v1/vaults | jq '.[] | {id, name}'

# Unset token from environment immediately
unset OP_API_TOKEN
```

### Integrations from this repo

**XPipe (MCP automation + hook)**

- Prefer MCP/HTTP automation to fetch a secret before connection. Pattern:
  1) XPipe automation calls a small script/binary that reads the token from a protected file/secret mount.
  2) Script calls `GET /v1/vaults/<vault>/items/<item>` with `Authorization: Bearer <token>`.
  3) It returns only the needed fields and hands them to XPipe as connection parameters (in-memory), then zeroes intermediates.
- Pre-connection hook fallback: a short script that reads the token from the protected file and exports the needed fields for the session only (no disk write of secrets). Do not store the token in XPipe config.

**XPipe MCP automation script (recommended):**

Create `/usr/local/bin/xpipe-op-fetch` with root-only permissions:

```bash
#!/usr/bin/env bash
set -euo pipefail

# XPipe 1Password Connect secret fetcher
# Usage: xpipe-op-fetch <vault-id> <item-id>
# Returns: JSON with username and password fields

TOKEN_FILE="/etc/op/connect/xpipe.token"
CONNECT_HOST="http://10.76.50.10:8080"

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <vault-id> <item-id>" >&2
    exit 1
fi

VAULT_ID="$1"
ITEM_ID="$2"

# Read token securely (requires root or sudo)
if [[ ! -r "$TOKEN_FILE" ]]; then
    echo "Error: Cannot read token file $TOKEN_FILE" >&2
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

# Fetch secret from Connect API
SECRET_JSON=$(curl -sf \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    "${CONNECT_HOST}/v1/vaults/${VAULT_ID}/items/${ITEM_ID}" 2>/dev/null)

if [[ -z "$SECRET_JSON" ]]; then
    echo "Error: Failed to fetch secret from Connect API" >&2
    exit 1
fi

# Extract credentials using jq
USERNAME=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.purpose=="USERNAME" or .label=="username") | .value' | head -n1)
PASSWORD=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.purpose=="PASSWORD" or .label=="password") | .value' | head -n1)

# Return as JSON for XPipe to parse
jq -n \
    --arg user "$USERNAME" \
    --arg pass "$PASSWORD" \
    '{username: $user, password: $pass}'

# Zero sensitive vars
TOKEN=""
SECRET_JSON=""
USERNAME=""
PASSWORD=""
```

**Setup script permissions:**

```bash
sudo chmod 700 /usr/local/bin/xpipe-op-fetch
sudo chown root:root /usr/local/bin/xpipe-op-fetch

# Test script manually (requires sudo)
sudo /usr/local/bin/xpipe-op-fetch <vault-id> <item-id>
# Expected: {"username":"...","password":"..."}
```

**XPipe pre-connection hook (simpler alternative):**

Create `/usr/local/bin/xpipe-op-env` for environment variable export:

```bash
#!/usr/bin/env bash
set -euo pipefail

# XPipe pre-connection secret injector
# Exports secrets as environment variables for current session only

TOKEN_FILE="/etc/op/connect/xpipe.token"
CONNECT_HOST="http://10.76.50.10:8080"
VAULT_ID="${1:-}"
ITEM_ID="${2:-}"

if [[ -z "$VAULT_ID" ]] || [[ -z "$ITEM_ID" ]]; then
    echo "Usage: source $0 <vault-id> <item-id>" >&2
    return 1 2>/dev/null || exit 1
fi

TOKEN=$(sudo cat "$TOKEN_FILE")

SECRET_JSON=$(curl -sf \
    -H "Authorization: Bearer $TOKEN" \
    "${CONNECT_HOST}/v1/vaults/${VAULT_ID}/items/${ITEM_ID}")

# Export for current session only (no disk writes)
export OP_USERNAME=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.purpose=="USERNAME") | .value')
export OP_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.purpose=="PASSWORD") | .value')

# Zero local vars
TOKEN=""
SECRET_JSON=""

echo "✓ Credentials loaded into environment (session-only)"
```

**XPipe connection configuration:**

1. In XPipe, create a new SSH connection
2. Go to **Advanced** → **Pre-Command**
3. Add:

   ```bash
   # For MCP automation approach:
   CREDS=$(sudo /usr/local/bin/xpipe-op-fetch <vault-id> <item-id>)
   export SSH_USER=$(echo $CREDS | jq -r '.username')
   export SSH_PASS=$(echo $CREDS | jq -r '.password')

   # Or for pre-connection hook:
   source /usr/local/bin/xpipe-op-env <vault-id> <item-id>
   export SSH_USER=$OP_USERNAME
   export SSH_PASS=$OP_PASSWORD
   ```

4. In connection fields, reference:
   - Username: `$SSH_USER`
   - Password: `$SSH_PASS`

5. Secrets are fetched dynamically per connection; no persistence in XPipe config.

**Ansible**

- Use the 1Password Connect Ansible collection. Supply `OP_CONNECT_HOST` and the token via environment only within the task execution, ideally sourced from an Ansible Vault or CI secret provider. No plaintext tokens in playbooks or inventory.
- Example pattern (conceptual): set `environment: OP_CONNECT_HOST`, `connect_token` from a vaulted var; call modules to fetch item fields; use `no_log: true` on secret-bearing tasks.

**Ansible playbook example:**

```yaml
---
- name: Deploy Pi-hole with secrets from 1Password Connect
  hosts: pihole_servers
  gather_facts: true
  
  vars:
    # Store in Ansible Vault or load from CI secret provider
    op_connect_token: "{{ lookup('env', 'OP_CONNECT_TOKEN') }}"
    op_connect_host: "http://10.76.50.10:8080"
    vault_name: "ServerVault Services"
    
  collections:
    - onepassword.connect
    
  tasks:
    - name: Fetch Pi-hole admin password from 1Password
      onepassword.connect.item_info:
        token: "{{ op_connect_token }}"
        item: "Pi-hole Admin"
        vault: "{{ vault_name }}"
      environment:
        OP_CONNECT_HOST: "{{ op_connect_host }}"
      register: pihole_secret
      no_log: true  # Prevent secrets from appearing in logs
      
    - name: Extract admin password from secret
      set_fact:
        pihole_admin_password: "{{ pihole_secret.op_item.fields | selectattr('label', 'equalto', 'password') | map(attribute='value') | first }}"
      no_log: true
      
    - name: Deploy Pi-hole container with secret password
      community.docker.docker_container:
        name: pihole
        image: pihole/pihole:latest
        env:
          WEBPASSWORD: "{{ pihole_admin_password }}"
          TZ: "America/Los_Angeles"
        ports:
          - "53:53/tcp"
          - "53:53/udp"
          - "80:80/tcp"
        restart_policy: unless-stopped
      no_log: true
      
    - name: Clear password from memory
      set_fact:
        pihole_admin_password: ""
      no_log: true
```

**Running the playbook securely:**

```bash
# Store Connect token in environment (loaded from secure file)
export OP_CONNECT_TOKEN=$(sudo cat /etc/op/connect/ansible.token)

# Run playbook
ansible-playbook -i inventory.yml deploy-pihole.yml

# Unset token immediately
unset OP_CONNECT_TOKEN
```

**Ansible Vault alternative (recommended for production):**

```bash
# Encrypt the Connect token in Ansible Vault
ansible-vault encrypt_string 'YOUR_CONNECT_TOKEN' --name 'op_connect_token' >> group_vars/all/vault.yml

# Reference vaulted variable in playbook:
# vars:
#   op_connect_token: "{{ vault_op_connect_token }}"

# Run with vault password
ansible-playbook -i inventory.yml deploy-pihole.yml --ask-vault-pass
```

**Other services**

- For apps in this repo, fetch secrets at startup via REST/SDK using per-app tokens loaded from secret mounts. Avoid baking tokens into images or configs.

### Verify

- `/health` returns ok.
- Token test: list vaults with a scoped token and confirm only intended vaults are visible.
- XPipe automation returns the expected secret fields and establishes a connection without persisting secrets.
- Ansible task fetches a secret field with `no_log: true` and succeeds.

**Verification commands:**

```bash
# 1. Test Connect API health
curl -f http://10.76.50.10:8080/health
# Expected: JSON with "name":"1Password Connect API", status indicators

# 2. Test Connect API heartbeat (simpler check)
curl -f http://10.76.50.10:8080/heartbeat
# Expected: .

# 3. List vaults with scoped token (load from secure file)
export OP_API_TOKEN=$(sudo cat /etc/op/connect/xpipe.token)
curl -s -H "Authorization: Bearer $OP_API_TOKEN" \
  http://10.76.50.10:8080/v1/vaults | jq '.[] | {id, name}'
# Expected: Only vaults authorized for this token

# 4. Fetch a specific item (test secret retrieval)
VAULT_ID="abc123xyz"
ITEM_ID="def456uvw"
curl -s -H "Authorization: Bearer $OP_API_TOKEN" \
  "http://10.76.50.10:8080/v1/vaults/${VAULT_ID}/items/${ITEM_ID}" | jq '.fields[] | {label, value}'
# Expected: Item fields with values

# 5. Test XPipe secret fetcher
sudo /usr/local/bin/xpipe-op-fetch $VAULT_ID $ITEM_ID
# Expected: {"username":"...","password":"..."}

# 6. Clean up
unset OP_API_TOKEN

# 7. Verify no secrets in environment
env | grep -i 'password\|token\|secret' || echo "✓ No secrets in environment"

# 8. Test Ansible integration
ansible-playbook -i localhost, test-connect.yml --check
# Expected: Playbook executes without errors; secrets fetched successfully
```

**Troubleshooting common issues:**

```bash
# Issue: Connection refused
# Solution: Verify Connect API is running and accessible
docker compose ps
docker compose logs connect-api

# Issue: 401 Unauthorized
# Solution: Verify token is valid and not expired
# Regenerate token if needed:
op connect token create xpipe-battlestar --server battlestar-connect --vault "Battlestar Secrets"

# Issue: 403 Forbidden (vault not accessible)
# Solution: Token lacks access to requested vault; create new token with proper vault scope

# Issue: Empty response from API
# Solution: Check item ID and vault ID are correct
curl -s -H "Authorization: Bearer $OP_API_TOKEN" \
  http://10.76.50.10:8080/v1/vaults | jq '.[]'
```

### Hardening & ops tips

- TLS: terminate at an internal proxy or enable TLS in Connect; consider mTLS for high-trust zones.
- Isolation: keep API on internal-only networks/VLANs; no public ingress.
- Logging/Audit: log token usage; alert on failed auth and unusual call rates.
- Backups: protect `1password-credentials.json` (identity); back up secrets store as per 1Password guidance; never commit it.
- Rotation & revocation: schedule rotation; revoke on role changes; re-issue per-service tokens when staff or services change.
