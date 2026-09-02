#!/bin/bash
export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre&|;rm -r /tmp/test;"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3...& user@host"

tmp_file=$(mktemp)
cp templates/runonce.sh.template "$tmp_file"

DELIM=$(printf '\001')

sed -i "s${DELIM}10\.10\.20\.X${DELIM}${future_ip}${DELIM}g" "$tmp_file"
sed -i "s${DELIM}10\.10\.20\.1${DELIM}${gateway}${DELIM}g" "$tmp_file"
sed -i "s${DELIM}cam-d1-XXX${DELIM}${hostname}${DELIM}g" "$tmp_file"
sed -i "s${DELIM}255\.255\.255\.0${DELIM}${netmask}${DELIM}g" "$tmp_file"
sed -i "s${DELIM}10\.10\.20\.1${DELIM}${dns}${DELIM}g" "$tmp_file"
sed -i "s${DELIM}op://homelab/CameraSSHPublicKey${DELIM}${ssh_key_content}${DELIM}g" "$tmp_file"

cat "$tmp_file"
rm "$tmp_file"
