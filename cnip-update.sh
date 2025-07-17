#! /usr/bin/env bash
#
#

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"

echo "Downloading cnv4 ip..."
#curl -sSL "https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone" -o "$TMP_DIR/cnv4.zone"
curl -sSL "https://github.com/DH-Teams/DH-Geo_AS_IP_CN/raw/refs/heads/main/Geo_AS_IP_CN.txt" -o "$TMP_DIR/cnv4.zone"
echo "Downloading cnv6 ip..."
#curl -sSL "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone" -o "$TMP_DIR/cnv6.zone"
curl -sSL "https://github.com/DH-Teams/DH-Geo_AS_IP_CN/raw/refs/heads/main/Geo_AS_IP_CN_6.txt" -o "$TMP_DIR/cnv6.zone"

for ip_type in cnv4 cnv6; do
    echo "Creating new $ip_type.nft..."
    tmp_file="$TMP_DIR/${ip_type}.nft"
    dst_file="$SCRIPT_DIR/${ip_type}.nft"
    echo "define _${ip_type}_list = {" > "$tmp_file"
    sed 's/^/  /; s/$/,/' "$TMP_DIR/${ip_type}.zone" >> "$tmp_file"
    echo "}" >> "$tmp_file"
    if [ ! -f "$dst_file" ] || ! cmp -s "$tmp_file" "$dst_file"; then
        cp -f "$tmp_file" "$dst_file"
        echo "Updated $dst_file"
    else
        echo "No need to update $ip_type.nft"
    fi
done

rm -rf "$TMP_DIR"
echo "Done."
