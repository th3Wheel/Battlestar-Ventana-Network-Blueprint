#!/bin/bash
export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3NzaC1...
second line"

awk '
function replace(str, search, repl) {
    result = ""
    while ((idx = index(str, search)) > 0) {
        result = result substr(str, 1, idx - 1) repl
        str = substr(str, idx + length(search))
    }
    return result str
}
{
    $0 = replace($0, "10.10.20.X", ENVIRON["future_ip"])
    $0 = replace($0, "10.10.20.1", ENVIRON["gateway"])
    $0 = replace($0, "cam-d1-XXX", ENVIRON["hostname"])
    $0 = replace($0, "255.255.255.0", ENVIRON["netmask"])
    $0 = replace($0, "10.10.20.1", ENVIRON["dns"])
    $0 = replace($0, "op://homelab/CameraSSHPublicKey", ENVIRON["ssh_key_content"])
    print $0
}
' templates/runonce.sh.template
