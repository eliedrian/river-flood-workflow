#!/bin/bash

# script to produce 1 week worth of logs from provided date and
# send them via email

set -e

report_date="$1"
start_date="$(date -d "$report_date -1 week" '+%Y-%m-%d')"

template_file="@etcdir@/report-email.tmpl"
subject="[RiverFlood] Workflow report"
mailing_list="$(< @etcdir@/weekly_report.list)"
to_address="$(paste -sd, <<< "$mailing_list")"

logs="$(journalctl \
	-u glofas-fetch.service \
	-u river-flood-process.service \
	-S "$start_date" --no-pager)"

echo "$logs"


