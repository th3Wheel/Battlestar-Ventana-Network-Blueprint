# 🔧 Infrastructure Automation

This directory contains infrastructure-as-code for the Battlestar Ventana Network Blueprint, with a focus on automated firewall rule generation and deployment.

---

## 📁 Directory Structure

```
infrastructure/
└── terraform/
    ├── firewall-automation.tf    # Main Terraform configuration
    ├── generated/                 # Auto-generated firewall rules (gitignored)
    │   ├── firewall-rules.sh     # UFW bash script
    │   └── firewall-rules.json   # JSON representation of rules
    └── README.md                  # This file
```

---

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.0
- Python 3.7+
- Access to the documentation files (`docs/services.md`, `docs/firewall-matrix.md`)

### Basic Usage

```bash
# Navigate to terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes (generates firewall rules)
terraform apply

# View outputs
terraform output
```

---

## 🔐 Firewall Rule Generation

The Terraform configuration automatically:

1. **Parses** firewall matrix and services documentation
2. **Generates** UFW (Uncomplicated Firewall) rules
3. **Creates** both bash script and JSON outputs
4. **Validates** rule determinism and correctness

### Generated Outputs

After running `terraform apply`, you'll find:

- **`generated/firewall-rules.sh`** - Ready-to-execute UFW configuration script
- **`generated/firewall-rules.json`** - Machine-readable rule definitions

### Applying Rules to a Host

```bash
# Copy the generated script to target host
scp generated/firewall-rules.sh user@target-host:/tmp/

# On the target host, apply the rules
ssh user@target-host
sudo bash /tmp/firewall-rules.sh

# Verify rules are applied
sudo ufw status verbose
```

---

## 🔄 Workflow

### 1. Update Documentation

Edit the source documentation:
- `docs/services.md` - Service and port definitions
- `docs/firewall-matrix.md` - VLAN access matrix

### 2. Regenerate Rules

```bash
cd infrastructure/terraform
terraform plan
terraform apply
```

### 3. Review Changes

```bash
# View the generated UFW script
cat generated/firewall-rules.sh

# View the JSON representation
cat generated/firewall-rules.json | python3 -m json.tool

# Check rule count
terraform output rule_count
```

### 4. Test in Staging

Before applying to production:
```bash
# Test on a staging host
scp generated/firewall-rules.sh staging-host:/tmp/
ssh staging-host "sudo bash /tmp/firewall-rules.sh"

# Verify connectivity
./test-connectivity.sh staging-host
```

### 5. Deploy to Production

See [Rollback Documentation](../../docs/firewall-rollback.md) for safe deployment procedures.

---

## 🧪 Testing

### Manual Testing

```bash
# Test script generation directly
python3 ../../scripts/services_to_ufw.py --format ufw --output /tmp/test.sh
python3 ../../scripts/services_to_ufw.py --format json --output /tmp/test.json

# Validate JSON
python3 -m json.tool /tmp/test.json

# Check determinism
python3 ../../scripts/services_to_ufw.py --format json --output /tmp/test1.json
python3 ../../scripts/services_to_ufw.py --format json --output /tmp/test2.json
diff /tmp/test1.json /tmp/test2.json
```

### Automated Testing

The CI workflow (`.github/workflows/firewall-validate.yml`) automatically:
- Validates Python script syntax
- Tests UFW and JSON rule generation
- Checks rule determinism
- Runs Terraform validation and plan
- Generates diff previews

---

## 📊 Terraform Outputs

The configuration provides these outputs:

| Output | Description |
|--------|-------------|
| `vlan_configuration` | Complete VLAN network configuration |
| `ufw_script_path` | Path to generated UFW script |
| `json_rules_path` | Path to generated JSON rules |
| `rule_count` | Total number of firewall rules |
| `rules_summary` | Complete summary with timestamps |

View outputs:
```bash
terraform output
terraform output -json
terraform output rule_count
```

---

## 🔍 Validation

### Rule Determinism

The system guarantees deterministic rule generation:
- Same input documentation → Same output rules
- Rules are sorted consistently
- No timestamps or random data in rules

### Automatic Regeneration

Rules are automatically regenerated when:
- `docs/services.md` changes
- `docs/firewall-matrix.md` changes
- `scripts/services_to_ufw.py` changes

This is tracked via file hashes in Terraform triggers.

---

## 🛠 Troubleshooting

### Issue: Terraform apply fails

```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Check for syntax errors
terraform fmt -check
```

### Issue: Script not found

```bash
# Verify script exists and is executable
ls -l ../../scripts/services_to_ufw.py
chmod +x ../../scripts/services_to_ufw.py
```

### Issue: Generated rules seem incorrect

```bash
# Manually test the conversion script
python3 ../../scripts/services_to_ufw.py --format ufw

# Check documentation files
cat ../../docs/firewall-matrix.md
cat ../../docs/services.md
```

---

## 📚 Related Documentation

- [Firewall Rollback Procedure](../../docs/firewall-rollback.md) - Safe rollback and recovery
- [Firewall Matrix](../../docs/firewall-matrix.md) - VLAN access rules  
- [Services Matrix](../../docs/services.md) - Service definitions
- [Audit Checklist](../../docs/audit-checklist.md) - Security verification

---

## 🔐 Security Considerations

1. **Review generated rules** before applying to production
2. **Test in staging** environment first
3. **Maintain backups** of current firewall rules
4. **Monitor logs** after applying changes
5. **Have rollback plan** ready before deployment
6. **Use version control** for all changes
7. **Audit regularly** against documentation

---

## 🔄 Continuous Deployment

For automated deployment:

```bash
# In CI/CD pipeline
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Copy rules to configuration management
cp generated/firewall-rules.sh /path/to/ansible/files/
cp generated/firewall-rules.json /path/to/config-mgmt/
```

---

## 📝 Maintenance

### Updating VLAN Configuration

To add or modify VLANs:

1. Update `docs/firewall-matrix.md` and `docs/services.md`
2. Update VLAN definitions in `scripts/services_to_ufw.py`
3. Update `locals.vlans` in `firewall-automation.tf` if needed
4. Regenerate rules: `terraform apply`

### Updating Service Ports

To add or modify services:

1. Update service definitions in `docs/services.md`
2. Update `SERVICE_PORTS` in `scripts/services_to_ufw.py`
3. Regenerate rules: `terraform apply`

---

## ✅ Best Practices

1. **Always review** generated rules before applying
2. **Test determinism** after making changes
3. **Version control** all documentation changes
4. **Document changes** in git commit messages
5. **Use CI/CD** for validation before merge
6. **Maintain backups** of working configurations
7. **Monitor actively** after applying changes

---

*For questions or issues, see [docs/firewall-rollback.md](../../docs/firewall-rollback.md) or open an issue.*
