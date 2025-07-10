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
for file in "domains/kl-nx-pioneers-testing.txt" "domains/kl-nx-pioneers-prod.txt"; do
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
echo "---testing test.sh kl-nx-pioneers-testing---"
sh test.sh kl-nx-pioneers-testing
echo "---testing test.sh kl-nx-pioneers-prod---"
sh test.sh kl-nx-pioneers-prod
