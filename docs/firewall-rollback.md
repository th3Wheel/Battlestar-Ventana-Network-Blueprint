# 🔄 Firewall Rollback Procedure

This document outlines the rollback and recovery procedures for the automated firewall rule generation system in the Battlestar Ventana Network Blueprint.

---

## 📋 Overview

The firewall automation system generates UFW (Uncomplicated Firewall) rules from the network documentation. If issues arise after applying generated rules, this guide will help you safely rollback changes.

---

## 🚨 Emergency Rollback

### Quick Rollback (Immediate)

If you need to immediately rollback firewall changes:

```bash
# Option 1: Disable UFW entirely (emergency only)
sudo ufw disable

# Option 2: Reset to previous backup
sudo ufw --force reset
sudo ufw --force enable
```

⚠️ **Warning**: Disabling UFW will leave your system unprotected. Only use this as a temporary emergency measure.

---

## 📦 Standard Rollback Procedure

### Step 1: Backup Current Rules

Before making any changes, always create a backup:

```bash
# Backup current UFW rules
sudo ufw status numbered > /tmp/ufw-backup-$(date +%Y%m%d-%H%M%S).txt

# Backup UFW configuration
sudo cp -r /etc/ufw /tmp/ufw-backup-$(date +%Y%m%d-%H%M%S)/
```

### Step 2: Identify Previous Working Version

```bash
# View git history of firewall-related files
cd /path/to/Battlestar-Ventana-Network-Blueprint
git log --oneline --all -- docs/firewall-matrix.md docs/services.md scripts/services_to_ufw.py

# Checkout a specific previous version
git checkout <commit-hash> -- docs/firewall-matrix.md docs/services.md
```

### Step 3: Regenerate Rules from Previous Version

```bash
# Generate rules from the checked-out version
python3 scripts/services_to_ufw.py --format ufw --output /tmp/rollback-rules.sh

# Review the generated rules
less /tmp/rollback-rules.sh
```

### Step 4: Apply Rollback Rules

```bash
# Make the script executable
chmod +x /tmp/rollback-rules.sh

# Apply the rollback rules (requires sudo)
sudo /tmp/rollback-rules.sh

# Verify the rules are applied
sudo ufw status verbose
```

### Step 5: Verify Network Connectivity

```bash
# Test connectivity to critical services
ping -c 3 10.76.50.1  # ServerVault gateway
ping -c 3 10.76.10.1  # Trusted LAN gateway
ping -c 3 8.8.8.8     # Internet connectivity

# Test specific services
nc -zv 10.76.50.10 443  # HTTPS to ServerVault
nc -zv 10.76.10.10 22   # SSH to management host
```

---

## 🔍 Verification Steps

### Pre-Deployment Verification

Before applying generated firewall rules, perform these checks:

#### 1. Validate Script Output

```bash
# Generate rules and check for errors
python3 scripts/services_to_ufw.py --format ufw --output /tmp/test-rules.sh
echo $?  # Should return 0 for success

# Check rule count is reasonable
wc -l /tmp/test-rules.sh
# Should be > 50 lines (adjust based on your network)
```

#### 2. Review Generated Rules

```bash
# Review the generated UFW script
less /tmp/test-rules.sh

# Check for suspicious or unexpected rules
grep -i "deny" /tmp/test-rules.sh
grep -i "0.0.0.0" /tmp/test-rules.sh
```

#### 3. Validate JSON Output

```bash
# Generate and validate JSON
python3 scripts/services_to_ufw.py --format json --output /tmp/test-rules.json

# Validate JSON syntax
python3 -m json.tool /tmp/test-rules.json > /dev/null
echo $?  # Should return 0

# Check rule count
python3 -c "import json; print(f'Rules: {len(json.load(open(\"/tmp/test-rules.json\"))[\"rules\"])}')"
```

#### 4. Test Determinism

```bash
# Generate rules twice and compare
python3 scripts/services_to_ufw.py --format json --output /tmp/rules1.json
python3 scripts/services_to_ufw.py --format json --output /tmp/rules2.json

diff /tmp/rules1.json /tmp/rules2.json
# Should output nothing (files are identical)
```

### Post-Deployment Verification

After applying firewall rules, verify network functionality:

#### 1. Basic Connectivity Tests

```bash
# Test VLAN-to-VLAN connectivity (examples)
# Trusted (10) -> ServerVault (50)
ping -c 3 10.76.50.1
curl -I https://10.76.50.10

# IoT (20) -> ServerVault (50) - MQTT
nc -zv 10.76.50.10 8883

# Guest (30) -> Internet (should work)
ping -c 3 8.8.8.8

# Guest (30) -> Trusted (10) (should fail)
ping -c 3 -W 2 10.76.10.1  # Should timeout
```

#### 2. Service-Specific Tests

```bash
# Test allowed services
# SSH to InfraCore from Trusted
ssh -o ConnectTimeout=5 user@10.76.40.10

# SMB to ServerVault from Trusted
smbclient -L //10.76.50.10 -N

# HTTPS to ServerVault
curl -k https://10.76.50.10

# Test blocked services (should fail)
# IoT -> SSH on InfraCore (should timeout)
ssh -o ConnectTimeout=5 user@10.76.40.10  # From IoT VLAN
```

#### 3. Monitoring and Logging

```bash
# Monitor UFW logs in real-time
sudo tail -f /var/log/ufw.log

# Check for blocked traffic
sudo grep "BLOCK" /var/log/ufw.log | tail -20

# View UFW status and rule count
sudo ufw status numbered | wc -l
```

---

## 🧪 Testing in Staging

Before applying to production:

### 1. Test in Isolated Environment

```bash
# Use a test VM or container
docker run -it --privileged ubuntu:22.04 /bin/bash

# Install UFW in container
apt-get update && apt-get install -y ufw

# Copy and test rules
# (copy rules to container and apply)
```

### 2. Gradual Rollout

1. Apply rules to a single test host first
2. Monitor for 24-48 hours
3. Gradually expand to more hosts
4. Roll back immediately if issues are detected

---

## 📊 Monitoring Checklist

After applying firewall rules, monitor these metrics:

- [ ] No increase in connection timeouts
- [ ] Critical services remain accessible
- [ ] No unexpected traffic blocks in logs
- [ ] Response times remain within acceptable ranges
- [ ] No user complaints about connectivity
- [ ] Monitoring systems can still reach all hosts
- [ ] Backup systems continue to function
- [ ] VPN connectivity remains stable

---

## 🔧 Troubleshooting

### Rules Not Applied

```bash
# Check UFW status
sudo ufw status

# If disabled, enable it
sudo ufw --force enable

# Reload rules
sudo ufw reload
```

### Unexpected Blocks

```bash
# Check recent blocks
sudo grep "BLOCK" /var/log/ufw.log | tail -20

# Temporarily allow specific traffic for testing
sudo ufw allow from 10.76.10.0/24 to 10.76.50.0/24

# Remove temporary rule after testing
sudo ufw status numbered
sudo ufw delete <rule-number>
```

### Script Generation Fails

```bash
# Check Python version
python3 --version  # Should be 3.7+

# Validate documentation files exist
ls -l docs/services.md docs/firewall-matrix.md

# Run script with verbose output
python3 -v scripts/services_to_ufw.py --format json
```

---

## 📝 Change Log Template

Document all firewall changes:

```markdown
### Firewall Change - [YYYY-MM-DD]

**Applied by**: [Name]
**Reason**: [Brief description]
**Commit**: [git commit hash]

**Pre-change backup**:
- Backup location: `/tmp/ufw-backup-YYYYMMDD-HHMMSS`
- Rule count: [number]

**Changes applied**:
- Generated rules from commit: [hash]
- Total rules: [number]
- Changes: [brief summary]

**Verification results**:
- [ ] Connectivity tests passed
- [ ] Service tests passed
- [ ] Monitoring checks passed

**Rollback plan**:
If issues arise, execute: `git checkout [previous-commit] && ./rollback.sh`
```

---

## 🔗 Related Documentation

- [Firewall Matrix](firewall-matrix.md) - VLAN access rules
- [Services Matrix](services.md) - Service and port definitions
- [Audit Checklist](audit-checklist.md) - Security verification
- [CI Workflow](../.github/workflows/firewall-validate.yml) - Automated validation

---

## 📞 Emergency Contacts

In case of critical firewall issues:

1. **Disable UFW immediately**: `sudo ufw disable`
2. **Document the issue**: Save logs and error messages
3. **Contact network administrator**: [Contact info]
4. **Create incident report**: Document timeline and impact

---

## ✅ Best Practices

1. **Always backup** before making changes
2. **Test in staging** before production
3. **Monitor actively** after changes
4. **Document everything** in git commit messages
5. **Use gradual rollout** for large changes
6. **Keep rollback plan ready** before applying changes
7. **Verify determinism** of rule generation
8. **Review generated rules** before applying

---

*Last updated: 2024-01-21*
