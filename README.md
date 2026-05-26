# China IPv4/IPv6 address segments in nftables set format.

## Data Source

- [DH-Teams/DH-Geo_AS_IP_CN](https://github.com/DH-Teams/DH-Geo_AS_IP_CN)

## Usage

    # Include the sets
    include "/path/to/cnip/cnv4.nft"
    include "/path/to/cnip/cnv6.nft"
    # Use in ruleset
    ip saddr @_cnv4_list accept
    ip6 saddr @_cnv6_list accept

## Manual Update

    ./cnip-update.sh

## Auto Update

GitHub Actions runs every Monday at 00:00 UTC, updates the data branch.

## Branches

- `master`: Source code (scripts, documentation)
- `data`: Generated nftables set files (auto-updated)

## Prerequisites

- Bash 4.0+
- curl
- sed
- cmp (part of coreutils)

## Troubleshooting

### Script fails to download

Check internet connection and verify GitHub is accessible.

### Permission denied

```bash
chmod +x cnip-update.sh
```
