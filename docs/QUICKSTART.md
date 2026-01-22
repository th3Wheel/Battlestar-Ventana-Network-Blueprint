# 🚀 Quick Start Guide - Firewall Automation

This guide provides quick examples for using the Battlestar Ventana firewall automation system.

---

## 📋 Prerequisites

- Python 3.7 or higher
- Terraform 1.0+ (for infrastructure automation)
- Access to the repository documentation

---

## 🔥 Quick Examples

### Generate UFW Rules (Bash Script)

```bash
# Generate UFW firewall rules
python3 scripts/services_to_ufw.py --format ufw --output firewall-rules.sh

# Review the generated script
cat firewall-rules.sh

# Apply to a host (requires sudo)
chmod +x firewall-rules.sh
sudo ./firewall-rules.sh
```

### Generate JSON Rules

```bash
# Generate JSON representation of rules
python3 scripts/services_to_ufw.py --format json --output firewall-rules.json

# Pretty-print the JSON
python3 -m json.tool firewall-rules.json

# Count rules
python3 -c "import json; print(len(json.load(open('firewall-rules.json'))['rules']))"
```

### Use with Terraform

```bash
# Navigate to terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes (generates rules automatically)
terraform apply

# View outputs
terraform output rules_summary
```

---

## 📊 Expected Output

When you run the script, you should see:

```
Generated 76 rules -> firewall-rules.sh
```

The generated UFW script includes:
- **Approximately 250+ lines** of bash script
- **76 firewall rules** covering all VLAN interactions
- **11 VLANs** configured
- **16 service types** (SSH, HTTPS, MQTT, SMB, etc.)

---

## ✅ Verification

### Test Determinism

```bash
# Generate rules twice
python3 scripts/services_to_ufw.py --format json --output test1.json
python3 scripts/services_to_ufw.py --format json --output test2.json

# Compare (should be identical)
diff test1.json test2.json
```

### Test JSON Validity

```bash
# Validate JSON syntax
python3 -m json.tool firewall-rules.json > /dev/null
echo $?  # Should return 0
```

### Test Python Syntax

```bash
# Validate script syntax
python3 -m py_compile scripts/services_to_ufw.py
echo "Script is valid"
```

---

## 🔍 Rule Breakdown

The system generates rules for these service types:

| Service Type | Rule Count | Protocol | Example Ports |
|-------------|------------|----------|---------------|
| All Services | 16 | any | All ports |
| HTTPS | 8 | tcp | 443 |
| RTSP | 8 | tcp | 554 |
| IPP | 7 | tcp | 631 |
| Chromecast | 5 | tcp | 8008-8009 |
| DLNA | 5 | udp | 1900 |
| SMB | 5 | tcp | 445 |
| Syslog | 4 | udp | 514 |
| SSH | 3 | tcp | 22 |
| MQTT | 2 | tcp | 8883 |
| ... and more | ... | ... | ... |

---

## 🎯 Common Use Cases

### 1. Update Firewall After Documentation Changes

```bash
# Edit documentation
vim docs/firewall-matrix.md
vim docs/services.md

# Regenerate rules
python3 scripts/services_to_ufw.py --format ufw --output firewall-rules.sh

# Review diff
git diff firewall-rules.sh

# Apply to hosts
# (use your deployment method)
```

### 2. Validate Before Deployment

```bash
# Generate and validate
python3 scripts/services_to_ufw.py --format json --output rules.json

# Check for errors
python3 -m json.tool rules.json

# Review specific rules
cat rules.json | grep "source_vlan.*10.76.10"

# Deploy to staging first
scp firewall-rules.sh staging-host:/tmp/
ssh staging-host "sudo bash /tmp/firewall-rules.sh"
```

### 3. CI/CD Integration

The repository includes `.github/workflows/firewall-validate.yml` that automatically:
- Validates rule generation
- Tests determinism
- Runs Terraform plan
- Generates diff previews

No manual intervention needed!

---

## 🛠 Troubleshooting

### Error: "Documentation directory not found"

```bash
# Check current directory
pwd

# Should be in repository root
cd /path/to/Battlestar-Ventana-Network-Blueprint

# Verify docs exist
ls -l docs/services.md docs/firewall-matrix.md
```

### Error: "Python module not found"

The script uses only standard library modules, no external dependencies needed:
- `json` (standard library)
- `argparse` (standard library)
- `pathlib` (standard library)
- `dataclasses` (Python 3.7+)

---

## 📚 Additional Resources

- [Infrastructure README](../infrastructure/README.md) - Detailed Terraform usage
- [Rollback Procedures](../docs/firewall-rollback.md) - Safe deployment and recovery
- [Firewall Matrix](../docs/firewall-matrix.md) - VLAN access rules
- [Services Matrix](../docs/services.md) - Service definitions

---

## 💡 Tips

1. **Always test in staging first**
2. **Backup current rules before applying**
3. **Monitor logs after deployment**
4. **Keep rollback script ready**
5. **Document all changes in git**
6. **Use CI/CD for validation**

---

*For complete documentation, see [infrastructure/README.md](../infrastructure/README.md)*
