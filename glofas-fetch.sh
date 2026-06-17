#!/bin/bash

date=$(date '+%Y%m%d')
username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

lftp "$username:$password@aux.ecmwf.int/fc_netcdf/" <<EOF
set net:max-retries 10
set net:reconnect-interval-base 5

mirror --verbose --continue "$date"
bye
EOF
