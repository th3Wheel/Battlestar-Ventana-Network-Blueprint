🚀 Enhancement Pack for Your DNS/DHCP Cluster

🧩 1. Ansible Role: roles/pihole_ha/

A role that installs Pi‑hole, Unbound, and keepalived with your preferred guardrails.

📁 Recommended Role Structure

roles/
  pihole_ha/
    tasks/
      main.yml
      pihole.yml
      unbound.yml
      keepalived.yml
      healthcheck.yml
    templates/
      keepalived.conf.j2
      unbound.conf.j2
    files/
      pihole_custom.list
    vars/
      main.yml
    handlers/
      main.yml
    meta/
      main.yml

🧠 Key Concepts

Idempotent: rerunning the role never breaks the node.

Secrets injected at runtime via 1Password CLI.

Health checks feed into keepalived track_script.

Floating IP is defined once in inventory and reused everywhere.

📝 Example tasks/main.yml

- name: Include Pi-hole tasks
  include_tasks: pihole.yml

- name: Include Unbound tasks
  include_tasks: unbound.yml

- name: Include keepalived tasks
  include_tasks: keepalived.yml

- name: Include healthcheck tasks
  include_tasks: healthcheck.yml

📝 Example templates/keepalived.conf.j2

vrrp_instance VI_1 {
  state {{ keepalived_state }}
  interface {{ keepalived_interface }}
  virtual_router_id {{ keepalived_vrid }}
  priority {{ keepalived_priority }}
  advert_int 1

  authentication {
    auth_type PASS
    auth_pass {{ keepalived_auth_pass }}
  }

  virtual_ipaddress {
    {{ keepalived_vip }}
  }

  track_script {
    chk_pihole
  }
}

vrrp_script chk_pihole {
  script "/usr/local/bin/pihole_healthcheck.sh"
  interval 5
  weight -20
}

🔐 2. Secrets: 1Password CLI Injection

This fits beautifully into your existing 1Password‑backed automation model.

🧩 Pattern: Use ansible.builtin.command + environment injection

Your inventory:

[dns_cluster]
dns1 ansible_host=10.10.5.21 keepalived_state=MASTER keepalived_priority=100
dns2 ansible_host=10.10.5.22 keepalived_state=BACKUP keepalived_priority=90

[dns_cluster:vars]
keepalived_vip=10.10.5.10
keepalived_vrid=51
keepalived_interface=eth0

Your playbook:

- hosts: dns_cluster
  vars:
    keepalived_auth_pass: "{{ lookup('ansible.builtin.env', 'KEEPALIVED_PASS') }}"
  roles:
  - pihole_ha

Your XPipe / VS Code task / Ansible wrapper:

export KEEPALIVED_PASS=$(op read "op://Homelab/DNS Cluster/keepalived_auth_pass")
ansible-playbook deploy_dns.yml

🧠 Why this works for you

No secrets ever touch disk.

Works identically on Proxmox LXC and physical SBCs.

Perfectly aligns with your existing 1Password + XPipe + Ansible guardrail stack.

📡 3. Monitoring: Prometheus + Home Assistant Sensors

You get both cluster‑level visibility and HA failover awareness.

📊 Prometheus Node Exporter

Add to your role:

- name: Install node exporter
  ansible.builtin.apt:
    name: prometheus-node-exporter
    state: present

Expose metrics:

CPU temp (important for H3 SBC)

Network throughput

VRRP state (via textfile collector)

Example VRRP state exporter:

/var/lib/node_exporter/textfile_collector/vrrp.prom

Contents:

keepalived_state{instance="{{ inventory_hostname }}"} 1

Your healthcheck script updates this file on state changes.

🏠 Home Assistant Sensors

You can expose:

Pi-hole stats via Pi-hole integration

Node exporter metrics via Prometheus integration

VRRP state via REST sensor or MQTT

Example REST sensor:

sensor:

- platform: rest
    name: DNS Cluster State
    resource: <http://10.10.5.10:9615/metrics>
    value_template: >
      {% if 'keepalived_state 1' in value %} MASTER {% else %} BACKUP {% endif %}

Or MQTT:

Your healthcheck script publishes:

mosquitto_pub -t homelab/dns/state -m "MASTER"

🧱 Putting It All Together

Your workflow becomes:

XPipe task

Inject secrets from 1Password

Run Ansible playbook

Validate configs

Ansible role

Deploy Pi-hole, Unbound, keepalived

Install health checks

Configure monitoring

Prometheus + HA

Observe VRRP state

Track DNS latency

Alert on failover

Proxmox LXC + H3 SBC

Identical configs

Identical secrets

Identical monitoring

This gives you a fully reproducible, fully observable, fully secret‑managed DNS/DHCP cluster that fits your architecture philosophy perfectly.
