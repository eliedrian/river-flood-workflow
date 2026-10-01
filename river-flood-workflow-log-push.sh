#!/bin/bash

set -e

logfile=$(pwd)

while getopts "f:" opt; do
	case $opt in
		f) logfile=$OPTARG ;;
	esac
done

cp "$logfile" "$REPOSITORY"/public/logs/workflow.log
git -C "$REPOSITORY" add public/logs/workflow.log
git -C "$REPOSITORY" commit -m "Automated log update"
git -C "$REPOSITORY" push
