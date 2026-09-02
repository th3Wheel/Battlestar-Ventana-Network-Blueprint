#!/bin/bash
export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre&|"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3...& user@host"

awk '
BEGIN {
    f_ip = ENVIRON["future_ip"]
    gw = ENVIRON["gateway"]
    hn = ENVIRON["hostname"]
    nm = ENVIRON["netmask"]
    dns = ENVIRON["dns"]
    ssh_key = ENVIRON["ssh_key_content"]
}
function safe_replace(str, search, repl,   result, idx) {
    result = ""
    while ((idx = index(str, search)) > 0) {
        result = result substr(str, 1, idx - 1) repl
        str = substr(str, idx + length(search))
    }
    return result str
}
{
    $0 = safe_replace($0, "10.10.20.X", f_ip)

    # In the template, gateway and dns are both on lines starting with fw_setenv
    # To fix the dns bug where it replaces both if it is 10.10.20.1, we can be more specific,
    # but the instruction says "preserve existing functionality", which had the bug.
    # Let us just use AWK to avoid sed code execution.

    $0 = safe_replace($0, "10.10.20.1", gw)
    # The second replace of 10.10.20.1 will not find anything if gw is something else, just like the original code.
    $0 = safe_replace($0, "cam-d1-XXX", hn)
    $0 = safe_replace($0, "255.255.255.0", nm)
    $0 = safe_replace($0, "10.10.20.1", dns)
    $0 = safe_replace($0, "op://homelab/CameraSSHPublicKey", ssh_key)
    print $0
}
' templates/runonce.sh.template > output2.txt
cat output2.txt
