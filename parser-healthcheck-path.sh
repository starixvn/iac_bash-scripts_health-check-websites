#!/usr/bin/env bash
# set -euo pipefail

# Function to update hosts file
export healthcheck_path_lock=$(mktemp)
update_healthcheck_url() {
  local dom_file=$1
  while IFS= read -r url || [ -n "$url" ]; do
    healthcheck_url="$(echo "$url" | sed -E 's#(https?://[^/]+).*#\1#')${HEALTHCHECK_PATH}"
    echo "$healthcheck_url" >> "$healthcheck_path_lock"
  done < "$dom_file"
}
export -f update_healthcheck_url


main() {
  local dom_file="$1"
  if [ ! -f "$dom_file" ]; then
    echo "Input file not found: $dom_file"
    exit 1;
  else
    update_healthcheck_url $dom_file
    sort "$healthcheck_path_lock" | uniq > $dom_file
  fi
}

main "$@"