#!/bin/bash

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y%m%d')
else
	date=$(date '+%Y%m%d')
fi

queue_file="$date.manifest"

files_to_download=10
if [[ ! -s "$queue_file" ]]; then
	printf '%02d\n' {0..50} | shuf -n "$files_to_download" > "$queue_file"
fi

mapfile -t nums < "$queue_file"

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

lftp "$username:$password@aux.ecmwf.int/fc_netcdf/$date" <<EOF
set cmd:verbose yes
set net:timeout 10
set net:max-retries 3
set net:reconnect-interval-base 5
set net:reconnect-interval-multiplier 1

mget -c -P 3 -d -O "$date" \
$(for n in "${nums[@]}"; do
	printf '"*_%s_*.nc" ' "$n"
done)
bye
EOF
