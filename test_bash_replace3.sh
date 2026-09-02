#!/bin/bash
var="foo&bar"
str="hello foo world"
str=${str//foo/"$var"}
echo "$str"
