#!/bin/bash

# Function to update hosts file
update_hosts() {
    local domain=$1
    local ip="58.84.9.42"
    
    # Remove existing entry if exists
    sed -i "/$domain/d" /etc/hosts
    # Add new entry
    echo "$ip $domain" | tee -a /etc/hosts > /dev/null
}

# Process domains from file
if [ -f "$1" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # Extract domain from URL
        domain=$(echo "$line" | sed -E 's#https?://([^/]+).*#\1#')
        update_hosts "$domain"
    done < "$1"
    cat /etc/hosts
else
    echo "File $1 not found!"
    exit 1
fi

# Run the original test script
chmod +x test.sh
echo "---testing test.sh $1 ---"
bash test.sh "$1"
