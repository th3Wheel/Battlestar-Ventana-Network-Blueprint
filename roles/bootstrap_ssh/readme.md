# bootstrap_ssh Role

Secure SSH key deployment using:

- 1Password lookup plugin
- No sshpass
- Host key verification enabled
- No plaintext secrets in repo or CLI args

## 1Password Vault Setup

This role retrieves the SSH password from 1Password using the `community.general.onepassword` lookup plugin. Before using this role, you must configure a 1Password item with the following structure:

### Item Configuration

- **Item Name**: `SSH Password`
- **Item Type**: Password (recommended) or Login
- **Required Fields**:
  - `password`: The SSH password for the target hosts

### Vault Setup Instructions

1. **Create the Item in 1Password**:
   - Open 1Password and navigate to the vault where you want to store the SSH password
   - Create a new item with the exact name `SSH Password`
   - Set the item type to "Password" or "Login"
   - In the password field, enter the SSH password for your target hosts

2. **Vault Name Conventions**:
   - No specific vault name is required by default
   - The lookup will search across all accessible vaults
   - For better organization, consider using a dedicated vault for infrastructure secrets (e.g., "Infrastructure", "Ansible", or "DevOps")
   - If using multiple vaults, ensure the 1Password CLI has access to the vault containing the `SSH Password` item

3. **1Password CLI Authentication**:
   - Install the 1Password CLI: `https://developer.1password.com/docs/cli/get-started/`
   - Authenticate using: `op signin` or configure service account authentication
   - Verify access: `op item get "SSH Password" --fields password`

4. **Ansible Requirements**:
   - Install the community.general collection: `ansible-galaxy collection install community.general`
   - Ensure the 1Password CLI (`op`) is available in your PATH

### Security Notes

- The password is never stored in plaintext in the repository
- The password is not exposed in command-line arguments or process listings
- The 1Password lookup occurs at runtime and credentials are only held in memory
- Consider using different SSH passwords per environment by creating environment-specific items (e.g., `SSH Password - Production`, `SSH Password - Staging`)

## Usage

Use in a playbook:

```yaml
- hosts: new_hosts
  roles:
    - bootstrap_ssh
```

### Customizing the 1Password Item Name

If you need to use a different item name, override the `ssh_password` variable in your playbook:

```yaml
- hosts: new_hosts
  roles:
    - bootstrap_ssh
  vars:
    ssh_password: >-
      {{ lookup(
          'community.general.onepassword',
          'Custom SSH Password Name',
          field='password'
      ) }}
```
