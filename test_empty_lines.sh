#!/bin/bash
cat << 'TXT' > input.txt
line1

line3

TXT
while IFS= read -r line || [[ -n "$line" ]]; do
    echo "[$line]"
done < input.txt
