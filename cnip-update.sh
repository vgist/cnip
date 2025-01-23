#! /usr/bin/env bash
#
#

set -ex

echo "Downloading cnv4 ip..."
curl -sSL https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone -o /tmp/cnv4.zone
echo "Downloading cnv6 ip..."
curl -sSL https://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone -o /tmp/cnv6.zone

_path=`pwd`

for i in cnv4 cnv6; do
    if ! diff /tmp/$i.zone $_path/$i.zone >/dev/null; then
        echo "Creating new $i.nft..."
        cp -f /tmp/$i.zone $_path/$i.zone
        echo "define _"$i"_list = {" > $_path/$i.nft
        sed "s/^/  /g; s/$/,/g" $_path/$i.zone >> $_path/$i.nft
        echo "}" >> $_path/$i.nft
    else
        echo "No need to update $i"
    fi
    rm /tmp/$i.zone
done
