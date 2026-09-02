#!/bin/bash
var="foo&bar"
str="hello foo world"
str="${str//foo/$var}"
echo "$str"

var2='foo&bar|baz'
str2="hello foo world"
str2="${str2//foo/$var2}"
echo "$str2"
