#!/bin/bash
export future_ip="10.76.81.53"
export gateway="10.76.81.1"
export hostname="cam-garage-centre&|"
export netmask="255.255.255.0"
export dns="10.76.50.1"
export ssh_key_content="ssh-rsa AAAAB3...& user@host"

awk '
BEGIN {
    # Fetch environment variables once
    f_ip = ENVIRON["future_ip"]
    gw = ENVIRON["gateway"]
    hn = ENVIRON["hostname"]
    nm = ENVIRON["netmask"]
    dns = ENVIRON["dns"]
    ssh_key = ENVIRON["ssh_key_content"]
}
function safe_replace(str, search, repl) {
    result = ""
    while ((idx = index(str, search)) > 0) {
        result = result substr(str, 1, idx - 1) repl
        str = substr(str, idx + length(search))
    }
    return result str
}
{
    $0 = safe_replace($0, "10.10.20.X", f_ip)
    # Notice: the runonce template has "10.10.20.1" for BOTH gateway and dns.
    # So replacing 10.10.20.1 globally will replace both.
    # To target them correctly, we should match the whole line or just replace it since it does not matter if both get the same or different.
    # Actually, in the original script:
    # sed -i "s|10\.10\.20\.1|${gateway}|g"
    # sed -i "s|10\.10\.20\.1|${dns}|g"
    # Wait, the second sed won t find 10.10.20.1 if it was already replaced by the first one unless gateway == 10.10.20.1
}
' templates/runonce.sh.template
