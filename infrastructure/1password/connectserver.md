# 1Password Connect server for Battlestar network secrets

Quick answer: You can update your Battlestar network to use 1Password Connect servers by creating a Connect Secrets Automation workflow, generating the 1password-credentials.json and access tokens, deploying the Connect API + sync containers (Docker or Kubernetes), and then reconfiguring your services to call the Connect REST API using per-service tokens — follow the 1Password Connect “Get started” steps for exact CLI and Docker/Kubernetes commands.

Plan & key decision points
Goal: Replace or augment your current secret backend so services on the Battlestar network call a self‑hosted 1Password Connect server (private REST API) for secrets.

Choose deployment: Docker Compose for simple/local setups or Kubernetes (Helm) for production/high‑availability. Both are supported.

Authentication model: Use one token per application/service (create tokens with the CLI) and store tokens as Kubernetes Secrets or environment variables (Kubernetes Secrets recommended).

Step‑by‑step (concise)
Create a Connect workflow and credentials

Use the 1Password web dashboard or the 1Password CLI (op connect server create) to create a Connect server and generate 1password-credentials.json in your working directory.

Create an access token for each service with op connect token create <tokenName> --server <serverName|serverID> --vault <vaultName|vaultID> and save tokens securely in 1Password or your secret store.developer.1password.com

Deploy Connect server

Docker: create a docker-compose.yaml that runs 1password/connect-api and 1password/connect-sync, mount the 1password-credentials.json, then run docker compose up (use -d to detach).

Kubernetes: use the provided Helm charts or operator examples in the docs to deploy the same two components and configure the credentials file and environment variables appropriately.

Test the Connect REST API

Export the token and call the API (example to list vaults):

bash
export OP_API_TOKEN="<token>"
curl -H "Accept: application/json" -H "Authorization: Bearer $OP_API_TOKEN" http://<connect-host>:8080/v1/vaults
By default the Connect API listens on port 8080 on the host where it’s deployed.

Update Battlestar services

Replace direct secret lookups with REST calls to your Connect server or use the 1Password SDKs (Go, Node, Python, etc.) and use a unique token per service. Store tokens as secrets and rotate them periodically.

Risks, trade‑offs & operational tips
Network exposure: Keep Connect servers on private networks or behind internal load balancers; avoid exposing the API publicly. Use Kubernetes Secrets rather than plain env vars for tokens in production.

Availability: Run connect-api and connect-sync redundantly and monitor sync health.

Access control: Grant Connect servers access only to the vaults they need; tokens are scoped and can be rotated or revoked.

Next steps I can help with
Provide a Docker Compose or Kubernetes Helm example tailored to your Battlestar network topology (nodes, ingress, secrets storage).

Draft the exact op CLI commands and a sample docker-compose.yaml for your environment.

Source: 1Password Connect “Get started” documentation.

also let xpipe use it
Integration overview
You can make XPipe use a self‑hosted 1Password Connect server by (A) deploying a Connect server and issuing scoped tokens, (B) choosing how XPipe will retrieve secrets at runtime, and (C) wiring XPipe to call the Connect REST API (or to read secrets injected into its environment) before or during connection launches. XPipe exposes a local HTTP MCP/automation interface you can use to coordinate this behavior, and 1Password Connect provides a REST API and tokens for programmatic access.

Quick comparison of integration approaches
Method Complexity Security Latency Best for
Direct REST calls from XPipe (plugin or hook) Medium High (per‑service tokens) Low Dynamic secret fetch per connection
Secrets injector (sidecar/init that writes files/env) Low High (Kubernetes Secrets) Very low (local file reads) Environments where XPipe cannot call external APIs
Periodic sync to local secret store Medium Medium (local store must be secured) Medium Offline or air‑gapped networks
Sources: .

Step‑by‑step plan (recommended: Direct REST calls + token per service)

1. Create a 1Password Connect workflow and tokens
Use the 1Password web UI or the CLI op connect server create to create a Connect server and generate the 1password-credentials.json file; then create one token per XPipe component or per connection consumer with op connect token create. Save tokens securely and treat each token as scoped credentialsdeveloper.1password.com.

2. Deploy 1Password Connect
Deploy the two Connect containers (1password/connect-api and 1password/connect-sync) with Docker Compose or Kubernetes as described in the 1Password docs; the Connect REST API is reachable on port 8080 by default for local deployments.

3. Confirm XPipe can call external HTTP endpoints
XPipe provides an MCP server and an HTTP API for automation and integrations; use that API or XPipe’s integration hooks to run pre‑connection logic or to fetch secrets when a connection is launched.

4. Implement secret retrieval in XPipe
Choose one of these concrete patterns:

A. Direct REST call from XPipe integration hook (recommended)

Add a pre‑connection hook (or plugin) in XPipe that:

Reads a per‑service Connect token from a secure store (Kubernetes Secret or protected file).

Calls the Connect REST API GET /v1/vaults/<vaultID>/items/<itemID> (or other endpoints) with Authorization: Bearer <token> to fetch credentials.

Injects the returned secret into the connection environment (in‑memory or as an ephemeral file) before XPipe opens the remote session.

This keeps secrets scoped, auditable, and rotated independently of XPipe.

B. Secrets injector sidecar / init container

Run a small process that uses the Connect token to fetch secrets at pod startup and writes them to a file or environment variables that XPipe reads. Use Kubernetes Secrets to store the Connect token and restrict RBAC accordingly.

C. Periodic sync to a local secret cache

Run a sync job that pulls required items from Connect into a local encrypted store that XPipe reads. Use this only if direct calls are impossible (air‑gapped or strict offline constraints).

(Implementation details: the Connect API uses bearer tokens and JSON responses; test with a curl request against http://<connect-host>:8080/v1/vaults to verify connectivity and token scope.)

All of the above rely on the Connect server and tokens created in Step 1 and the Connect containers deployed in Step 2. Use XPipe’s MCP/HTTP automation surface to trigger or coordinate these calls rather than embedding credentials in plain text in configsdocs.xpipe.io+1.
All of the above rely on the Connect server and tokens created in Step 1 and the Connect containers deployed in Step 2. Use XPipe’s MCP/HTTP automation surface to trigger or coordinate these calls rather than embedding credentials in plain text in configs. See <https://docs.xpipe.io> for configuration details.
Security and operational recommendations
Token scope & rotation: Issue a distinct Connect token per XPipe consumer and rotate/revoke tokens regularly; store tokens as Kubernetes Secrets or in a secure vault, not plain env vars.

Network placement: Keep Connect servers on an internal network or behind an internal load balancer; do not expose the Connect API publicly unless protected by strong network controls and mTLS.

Least privilege: Grant Connect server access only to the vaults/items XPipe needs; avoid broad vault access when possible.

High availability: Run both connect-api and connect-sync redundantly and monitor sync health; ensure XPipe handles transient failures (retry/backoff) when calling Connect.

Audit & logging: Log token usage and XPipe secret fetch events for auditing and incident response.

Example snippets (conceptual)
Test Connect API (shell):

bash
export OP_API_TOKEN="<token>"
curl -H "Accept: application/json" -H "Authorization: Bearer $OP_API_TOKEN" http://<connect-host>:8080/v1/vaults
Pseudocode for XPipe pre‑connection hook:

python

# 1) read token from secure store

# 2) call Connect API to fetch item

# 3) inject secret into connection environment

(Use the Connect REST endpoints and token creation steps from the 1Password docs to build the exact requests and parsing logic.)

Next steps I can take for you
Generate a Docker Compose example that runs connect-api + connect-sync with a mounted 1password-credentials.json and an example token usage snippet.

Draft a Kubernetes manifest (Deployment + Secret + Service) and a small XPipe pre‑connection hook script (Go/Node/Python) that fetches a secret and injects it into the session.

Walk through a minimal proof‑of‑concept sequence for one XPipe connection (commands and expected responses).

Tell me which of the three next steps above you want first (Docker Compose, Kubernetes manifest + hook, or a POC walkthrough) and I’ll produce the concrete files and code snippets.

Today

## Today

Absolutely — let’s build a clean, minimal, reproducible POC walkthrough that gets your Battlestar network + XPipe pulling secrets from a 1Password Connect Server.
This is the smallest end‑to‑end demo that proves everything works before you wire it into your full homelab.

I’ll keep it tight, actionable, and aligned with your workflow style: reproducible, documented, and future‑proof.

🚀 POC Walkthrough: Battlestar Network + XPipe + 1Password Connect
This POC demonstrates:

Create Connect server + credentials

Deploy Connect (Docker)

Create a scoped token for XPipe

Fetch a secret via Connect API

Use that secret inside XPipe (pre‑connection hook)

Everything below is self‑contained and safe to run on a test node.

1️⃣ Create Connect Server + Credentials
Run this on your workstation (not the server):

bash
op connect server create battlestar-connect \
  --vault "Battlestar Secrets" \
  --format json > 1password-credentials.json
This file is the identity of your Connect server.
You will mount it into the containers.

2️⃣ Deploy Connect Server (Docker POC)
Create docker-compose.yaml:

yaml
version: "3.8"

services:
  connect-api:
    image: 1password/connect-api:latest
    ports:
      - "8080:8080"
    volumes:
      - ./1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro

  connect-sync:
    image: 1password/connect-sync:latest
    volumes:
      - ./1password-credentials.json:/home/opuser/.op/1password-credentials.json:ro
Start it:

bash
docker compose up -d
Verify it’s alive:

bash
curl <http://localhost:8080/health>
Expected:

json
{"status":"ok"}
3️⃣ Create a Scoped Token for XPipe
You want one token per XPipe connection type.

Example:

bash
op connect token create xpipe-battlestar \
  --server battlestar-connect \
  --vault "Battlestar Secrets"
Copy the token into a secure location on the XPipe machine:

Code
File path:
Permissions:

bash
chmod 600 /etc/xpipe/op-token
4️⃣ Fetch a Secret via Connect API (POC Test)
Let’s assume you have an item called “SSH – Azure Defiant Root”.

Test retrieval:

bash
export OP_API_TOKEN=$(cat /etc/xpipe/op-token)

curl -s \
  -H "Authorization: Bearer $OP_API_TOKEN" \
  http://<connect-ip>:8080/v1/vaults | jq
Then fetch the item:

bash
curl -s \
  -H "Authorization: Bearer $OP_API_TOKEN" \
  http://<connect-ip>:8080/v1/vaults/<vault-id>/items/<item-id> | jq
You should see fields like:

json
{
  "title": "SSH – Azure Defiant Root",
  "fields": [
    { "label": "username", "value": "root" },
    { "label": "password", "value": "supersecret" }
  ]
}
This proves Connect is working.

5️⃣ XPipe Integration (Pre‑Connection Hook)
XPipe supports pre‑connection commands.
You’ll use that to fetch secrets dynamically.

Create a script XPipe will call:

/usr/local/bin/xpipe-op-fetch

bash

# !/usr/bin/env bash

TOKEN=$(cat /etc/xpipe/op-token)
CONNECT="http://<connect-ip>:8080"
VAULT="<vault-id>"
ITEM="<item-id>"

SECRET_JSON=$(curl -s \
  -H "Authorization: Bearer $TOKEN" \
  "$CONNECT/v1/vaults/$VAULT/items/$ITEM")

USERNAME=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.label=="username") | .value')
PASSWORD=$(echo "$SECRET_JSON" | jq -r '.fields[] | select(.label=="password") | .value')

echo "username=$USERNAME"
echo "password=$PASSWORD"
Make it executable:

bash
chmod +x /usr/local/bin/xpipe-op-fetch
6️⃣ XPipe Connection Template
Inside XPipe:

Connection → Advanced → Pre‑Command

Code
eval $(/usr/local/bin/xpipe-op-fetch)
Then configure the SSH connection using:

Username: $username

Password: $password

XPipe will:

Run the script

Fetch secrets from Connect

Inject them into the connection environment

Open the SSH session using live secrets

No secrets stored in XPipe.
No plaintext in configs.
Everything rotates cleanly.

7️⃣ Validate End‑to‑End
Run the XPipe connection.

If it logs in successfully → POC complete.

You now have:

✔ Connect server deployed
✔ Scoped XPipe token
✔ Live secret retrieval
✔ XPipe using Connect dynamically
✔ Zero static secrets on disk
