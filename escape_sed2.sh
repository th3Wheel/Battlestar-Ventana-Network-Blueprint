#!/bin/bash
escape_sed() {
    # Escape delimiter (|), backslash (\), and ampersand (&)
    printf '%s' "$1" | sed 's/[|\&]/\\&/g'
}

export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre&|;hello"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3...& user@host"

tmp_file=$(mktemp)
cp templates/runonce.sh.template "$tmp_file"

# We must escape the variables for the replacement string.
# Also newlines?
ssh_key_content_esc=$(escape_sed "$ssh_key_content" | sed -z 's/\n/\\n/g')
future_ip_esc=$(escape_sed "$future_ip")
gateway_esc=$(escape_sed "$gateway")
hostname_esc=$(escape_sed "$hostname")
netmask_esc=$(escape_sed "$netmask")
dns_esc=$(escape_sed "$dns")

sed -i "s|10\.10\.20\.X|${future_ip_esc}|g" "$tmp_file"
sed -i "s|10\.10\.20\.1|${gateway_esc}|g" "$tmp_file"
sed -i "s|cam-d1-XXX|${hostname_esc}|g" "$tmp_file"
sed -i "s|255\.255\.255\.0|${netmask_esc}|g" "$tmp_file"
sed -i "s|10\.10\.20\.1|${dns_esc}|g" "$tmp_file"
sed -i "s|op://homelab/CameraSSHPublicKey|${ssh_key_content_esc}|g" "$tmp_file"

cat "$tmp_file"
rm "$tmp_file"
