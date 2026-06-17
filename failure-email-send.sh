#!/bin/bash

unit="$1"

templatefile="/etc/river-flood-workflow/failure-email.tmpl"
subject="[RiverFlood] Workflow failure"
mailinglist="$(< /etc/river-flood-workflow/mailing.list)"
toaddress="$(paste -sd, <<< "$mailinglist")"
logs="$(journalctl -u "$unit" -n 200 --no-pager)"
encodedlogs="$(base64 -w 0 <<< "$logs")"

render() {
	sed \
		-e "s/{{TO_ADDRESS}}/$toaddress/g" \
		-e "s/{{SUBJECT}}/$subject/g" \
		-e "s/{{UNIT}}/$unit/g" \
		-e "s/{{LOGS}}/$encodedlogs/g" \
		"$templatefile"
}

rendered="$(render)"

echo "$rendered"

msmtp -a default -t -- <<EOF
$rendered
EOF
