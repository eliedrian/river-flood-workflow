#!/bin/bash

report_date="$1"
start_date="$(date -d "$report_date -1 week" '+%Y-%m-%d')"

template_file="/etc/river-flood-workflow/report-email.tmpl"
subject="[RiverFlood] Workflow report"
mailing_list="$(< /etc/river-flood-workflow/mailing.list)"
to_address="$(paste -sd, <<< "$mailing_list")"

logs="$(journalctl \
	-u glofas-fetch.service \
	-u river-flood-process.service \
	-S "$start_date" --no-pager)"

echo "$logs"
