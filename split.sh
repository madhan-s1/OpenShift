#!/bin/bash
# split.sh

input="combined.yamlbundle"
out=""

while IFS= read -r line; do
  if [[ "$line" =~ ^###\ FILE:\ (.*)\ ###$ ]]; then
    filepath="${BASH_REMATCH[1]}"
    mkdir -p "$(dirname "$filepath")"
    out="$filepath"
    > "$out"
  elif [[ -n "$out" ]]; then
    echo "$line" >> "$out"
  fi
done < "$input"

echo "✅ Split complete — clean filenames restored."

