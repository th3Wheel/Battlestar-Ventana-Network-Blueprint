#!/bin/bash
escape_sed() {
  printf "%s" "$1" | sed -e 's/[\/&]/\\&/g'
}

echo "$(escape_sed "hello&world/test")"
