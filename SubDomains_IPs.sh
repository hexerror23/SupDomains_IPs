#!/bin/bash

echo "Please Enter The Root Domain (example.com)"
read domain

# Download the index.html of the root domain
wget -q "http://$domain" -O index.html


# Filter only valid subdomains of the given root domain
cat index.html | grep -oP 'href="http[s]?://\K[^"]+' | \grep -P "\.$domain" | \sed 's/^www\.//g' | \sort | uniq > subdomains.txt

# Check if subdomains are live or not
for sub in $(cat subdomains.txt)
do
    if [[ $(ping -c 1 $sub 2> /dev/null) ]]
    then
        echo "$sub is live"
        echo "$sub" >> live_sub.txt
    else
        echo "$sub is down"
    fi
done

# Check for IPs
for ips in $(cat live_sub.txt)
do
    ip=$(ping -c 1 "$ips" | head -n 1 | cut -d '(' -f 2 | cut -d ')' -f 1)
    if [[ -n "$ip" ]]; then
        echo "$ip" >> sub_ip.txt
    fi
done

echo "Subdomains with IPs are saved in sub_ip.txt"
