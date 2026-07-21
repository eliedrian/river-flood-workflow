#!/bin/bash
files_to_download=10

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y%m%d')
else
	date=$(date '+%Y%m%d')
fi

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

nums=($(printf '%02d\n' {0..50} | shuf -n "$files_to_download"))

mkdir "$date"

lftp "$username:$password@aux.ecmwf.int/fc_netcdf/$date" <<EOF
set net:timeout 10
set net:max-retries 3
set net:reconnect-interval-base 5
set net:reconnect-interval-multiplier 1

mget --continue --parallel 3 --verbose --target-directory "$date" \
$(for n in "${nums[@]}"; do
	printf '"*_%s_*.nc" ' "$n"
done)
bye
EOF
