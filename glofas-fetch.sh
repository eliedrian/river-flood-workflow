#!/bin/bash

date=$(date +%Y%m%d)
outdir=$(pwd)

while getopts ":d:o:" opt; do
	case $opt in
		d) date=$OPTARG ;;
		o) outdir=$OPTARG ;;
	esac
done

username=$(<$CREDENTIALS_DIRECTORY/username)
password=$(<$CREDENTIALS_DIRECTORY/password)

lftp <<EOF
open -u "$username","$password" ftp://aux.ecmwf.int/for_Phillippines
set net:timeout 10
set net:max-retries 3
set net:reconnect-interval-base 5
set net:reconnect-interval-multiplier 1

get -c glofas_areagrid_for_Phillippines_in_Phillippines_"$date"00.nc -O "$outdir"
bye
EOF
