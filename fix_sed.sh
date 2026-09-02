#!/bin/bash
export ip="10.10.10.1"
export host="myhost/foo"

AWK_SCRIPT='
BEGIN {
    ip = ENVIRON["ip"]
    host = ENVIRON["host"]
}
{
    if ($0 ~ /^ip_address=/) {
        print "ip_address=" ip
    } else if ($0 ~ /^hostname=/) {
        print "hostname=" host
    } else {
        print $0
    }
}
'

awk "$AWK_SCRIPT" templates/thingino.conf.template
