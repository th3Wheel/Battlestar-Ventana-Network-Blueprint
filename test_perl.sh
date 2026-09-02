#!/bin/bash
export VAR='$& $1 @foo \n'
echo "hello world" > input.txt
perl -pe 's/world/$ENV{VAR}/g' input.txt
