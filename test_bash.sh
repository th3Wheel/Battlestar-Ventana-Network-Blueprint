#!/bin/bash
future_ip="10.76.81.53"
gateway="10.76.81.1"
hostname="cam-garage-centre"
netmask="255.255.255.0"
dns="10.76.50.1"
ssh_key_content="ssh-rsa AAAAB3NzaC1...
second line"

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//10.10.20.X/$future_ip}"
    line="${line//10.10.20.1/$gateway}"
    line="${line//cam-d1-XXX/$hostname}"
    line="${line//255.255.255.0/$netmask}"
    line="${line//10.10.20.1/$dns}"

    # For ssh key which contains /
    search="op://homelab/CameraSSHPublicKey"
    line="${line//$search/$ssh_key_content}"

    echo "$line"
done < templates/runonce.sh.template
