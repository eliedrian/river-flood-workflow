#!/bin/bash

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y%m%d')
else
	date=$(date '+%Y%m%d')
fi

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

lftp "$username:$password@aux.ecmwf.int/for_Phillippines" <<EOF
set cmd:verbose yes
set net:timeout 10
set net:max-retries 3
set net:reconnect-interval-base 5
set net:reconnect-interval-multiplier 1

get -c "glofas_areagrid_for_Phillippines_in_Phillippines_$date00.nc" -O "$date"
bye
EOF
