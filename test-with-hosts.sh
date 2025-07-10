#!/bin/bash

# Function to update hosts file
update_hosts() {
    local domain=$1
    local ip="58.84.9.42"
    
    # Remove existing entry if exists
    sed -i "/$domain/d" /etc/hosts
    
    # Add new entry
    echo "$ip $domain" | tee -a /etc/hosts > /dev/null
    cat /etc/hosts
}

# Process domains from files
for file in "domains/lumi-prod.txt" "domains/nexcel-prod.txt"; do
    if [ -f "$file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            # Extract domain from URL
            domain=$(echo "$line" | sed -E 's#https?://([^/]+).*#\1#')
            update_hosts "$domain"
        done < "$file"
    else
        echo "File $file not found!"
    fi
done

# Run the original test script
chmod +x test.sh
echo "---testing test.sh lumi-prod---"
sh test.sh lumi-prod
echo "---testing test.sh nexcel-prod---"
sh test.sh nexcel-prod
