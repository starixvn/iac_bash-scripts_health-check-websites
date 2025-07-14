#!/bin/bash

# Function to update hosts file
update_hosts() {
    local domain=$1
    local ip_host_map=$2
    # Remove existing entry if exists
    sed -i "/$domain/d" /etc/hosts
    # Add new entry
    echo "$ip_host_map $domain" | tee -a /etc/hosts > /dev/null
}

# Process domains from file
if [ -f "$1" ]; then
    # Select IP HOST MAP Address
    if [[ "$CI_COMMIT_TAG" =~ ^aws ]]; then
        ip_host_map="$IP_HOST_MAP_AWS_SG"
    else
        ip_host_map="$IP_HOST_MAP_KL"
    fi

    # Update hosts file
    while IFS= read -r line || [ -n "$line" ]; do
        domain=$(echo "$line" | sed -E 's#https?://([^/]+).*#\1#')
        update_hosts "$domain" "$ip_host_map"
    done < "$1"
    cat /etc/hosts
else
    echo "File $1 not found!"
    exit 1
fi
