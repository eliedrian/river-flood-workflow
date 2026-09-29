#!/bin/bash

set -e

since=$(date -d '1 week ago' +%Y-%m-%d)

while getopts "S:o:" opt; do
	case $opt in
		S) since=$OPTARG ;;
		o) outfile=$OPTARG ;;
	esac
done

if [[ -n "$outfile" ]]; then
	exec > "$outfile"
fi

journalctl -u glofas-fetch -u river-flood-process -S "$since" --no-pager
