#! /usr/bin/env bash
#
#

set -ex
trap 'rm -rf "$TMP_DIR"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"

# Check dependencies
for cmd in curl sed cmp; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Data source URL
DATA_REPO="DH-Teams/DH-Geo_AS_IP_CN"
DATA_BRANCH="main"
DATA_BASE_URL="https://github.com/${DATA_REPO}/raw/refs/heads/${DATA_BRANCH}"

# Download with retry
max_retries=3

echo "Downloading cnv4 ip..."
retry_count=0
until curl -sSL "${DATA_BASE_URL}/Geo_AS_IP_CN.txt" -o "$TMP_DIR/cnv4.zone"; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
        echo "Error: Failed to download cnv4 data after $max_retries attempts" >&2
        exit 1
    fi
    echo "Retry $retry_count/$max_retries..."
    sleep 2
done

echo "Downloading cnv6 ip..."
retry_count=0
until curl -sSL "${DATA_BASE_URL}/Geo_AS_IP_CN_6.txt" -o "$TMP_DIR/cnv6.zone"; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
        echo "Error: Failed to download cnv6 data after $max_retries attempts" >&2
        exit 1
    fi
    echo "Retry $retry_count/$max_retries..."
    sleep 2
done

# Verify downloaded files
if [ ! -s "$TMP_DIR/cnv4.zone" ]; then
    echo "Error: cnv4.zone is empty or missing" >&2
    exit 1
fi
if [ ! -s "$TMP_DIR/cnv6.zone" ]; then
    echo "Error: cnv6.zone is empty or missing" >&2
    exit 1
fi

for ip_type in cnv4 cnv6; do
    echo "Creating new $ip_type.nft..."
    tmp_file="$TMP_DIR/${ip_type}.nft"
    dst_file="$SCRIPT_DIR/${ip_type}.nft"
    echo "define _${ip_type}_list = {" > "$tmp_file"
    sed '/^$/d; s/^/  /; s/$/,/' "$TMP_DIR/${ip_type}.zone" >> "$tmp_file"
    # Remove trailing comma from last line (nftables syntax requirement)
    sed -i '$ s/,$//' "$tmp_file"
    echo "}" >> "$tmp_file"
    if [ ! -f "$dst_file" ] || ! cmp -s "$tmp_file" "$dst_file"; then
        cp -f "$tmp_file" "$dst_file"
        echo "Updated $dst_file"
    else
        echo "No need to update $ip_type.nft"
    fi
done

echo "Done."
