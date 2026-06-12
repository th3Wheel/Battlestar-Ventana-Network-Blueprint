# 🚦 Rate-Limiting Strategy — Battlestar Ventana Network Blueprint

## 🔐 SYN Flood Protection

Policy target: **20 SYN/sec/IP**.

Use `hashlimit` for per-source-IP enforcement:

```bash
iptables -A INPUT -p tcp --syn -m hashlimit --hashlimit-above 20/second --hashlimit-burst 40 --hashlimit-mode srcip --hashlimit-name syn_per_ip -j DROP
```
