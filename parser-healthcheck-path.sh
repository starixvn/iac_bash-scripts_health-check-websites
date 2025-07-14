#!/usr/bin/env bash
set -euo pipefail

# Function to update hosts file
export healcheck_path_lock=$(mktemp)
update_healthcheck_url() {
  local DOM_FILE=$1
  while IFS= read -r url || [ -n "$url" ]; do
    healthcheck_url="$(echo "$url" | sed -E 's#https?://([^/]+).*#\1#')${HEALTHCHECK_PATH}"
    echo "$healthcheck_url" >> "$healcheck_path_lock"
  done
}
export -f update_healthcheck_url


main() {
  local dom_file="$1"
  if [ ! -f "$dom_file" ]; then
    echo "Input file not found: $dom_file"
    exit 1;
  else
    echo $dom_file
  fi

  update_healthcheck_url $dom_file
  sort "$healcheck_path_lock" | uniq > $dom_file
}

main "$@"