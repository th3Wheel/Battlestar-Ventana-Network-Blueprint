#!/bin/bash
escape_sed() {
    # Escape delimiter (|), backslash (\), and ampersand (&), and newline (\n)
    printf '%s' "$1" | sed -e 's/[|\&]/\\&/g' -e 's/$/\\n/' | tr -d '\n' | sed 's/\\n$//'
}

echo "$(escape_sed $'hello\nworld&|test')"
