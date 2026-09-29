#!/bin/bash

set -e

logfile=$(pwd)

while getopts "f:" opt; do
	case $opt in
		f) logfile=$OPTARG ;;
	esac
done

cp "$logfile" "$REPOSITORY"/public/logs
git -C "$REPOSITORY" add "$logfile"
git -C "$REPOSITORY" commit -m "Automated log update"
git -C "$REPOSITORY" push
