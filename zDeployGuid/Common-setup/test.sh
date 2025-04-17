#!/bin/bash

inventory_file="$1"
group_name="$2"

# Bước 1: Lấy danh sách host thuộc group
hosts=$(ansible-inventory -i "$inventory_file" --list | \
        awk -v group="\\\"$group_name\\\"" '
            $0 ~ group": {" {found=1; next}
            found && /\]/ {exit}
            found && /"/ {
                gsub(/[",]/, "", $1)
                print $1
            }
        ')

# Bước 2: Với mỗi host, tìm IP trong hostvars
for host in $hosts; do
    ip=$(ansible-inventory -i "$inventory_file" --list | \
        awk -v host="\"$host\"" '
            $0 ~ host": {" {found=1; next}
            found && /ansible_host/ {
                match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/, m)
                print m[0]
                exit
            }
        ')
    if [[ -n "$ip" ]]; then
        echo "$ip"
    fi
done

