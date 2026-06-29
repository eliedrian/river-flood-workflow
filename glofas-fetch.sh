#!/bin/bash

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y%m%d')
else
	date=$(date '+%Y%m%d')
fi

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

lftp "$username:$password@aux.ecmwf.int/fc_netcdf/" <<EOF
set net:max-retries 10
set net:reconnect-interval-base 5

mirror --parallel 3 --verbose --continue "$date"
bye
EOF
