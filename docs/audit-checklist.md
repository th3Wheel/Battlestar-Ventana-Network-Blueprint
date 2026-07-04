# 📋 Audit Checklist — Battlestar Ventana Network Blueprint

This file provides a structured audit checklist for the Battlestar Ventana Network Blueprint.  
Use it to validate that all VLANs, firewall rules, and service flows adhere to policy.

---

## ✅ Operational Health Checklist

```csv
Audit Item, Requirement, Pass/Fail
Guest VLAN, Must be isolated from LANs, 
IoT VLAN, Restricted to telemetry only (MQTT/HTTPS), 
Cameras, View-only from Trusted VLAN, 
Work VLAN (90), Internet unthrottled; VPN bootstraps via local DNS/DHCP, 
ServerVault, Outbound limited to updates and sync, 
```  

---

## 🧾 Documentation Maintenance Guardrails

- Changelog maintenance is currently paused to reduce code and docs churn.

---

## 🔗 References

- [Firewall Matrix](firewall-matrix.md)  
- [Services Matrix](services.md)
