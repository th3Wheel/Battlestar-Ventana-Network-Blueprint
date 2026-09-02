#!/bin/bash
export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre&|"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3...& user@host"

tmp_file=$(mktemp)

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//10.10.20.X/"$future_ip"}"
    line="${line//10.10.20.1/"$gateway"}"
    line="${line//cam-d1-XXX/"$hostname"}"
    line="${line//255.255.255.0/"$netmask"}"
    line="${line//10.10.20.1/"$dns"}"

    # ssh key replacement
    search="op://homelab/CameraSSHPublicKey"
    line="${line//$search/"$ssh_key_content"}"

    printf "%s\n" "$line" >> "$tmp_file"
done < templates/runonce.sh.template

cat "$tmp_file"
rm "$tmp_file"
