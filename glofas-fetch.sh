#!/bin/bash
files_to_download=10

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y%m%d')
else
	date=$(date '+%Y%m%d')
fi

echo "$date"

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

nums=($(printf '%02d\n' {0..50} | shuf -n "$files_to_download"))

lftp "$username:$password@aux.ecmwf.int/fc_netcdf/$date" <<EOF
set net:max-retries 10
set net:reconnect-interval-base 5

$(for n in "${nums[@]}"; do
	printf 'mget --continue "*_%s_*.nc"\n' "$n"
done)
bye
EOF
