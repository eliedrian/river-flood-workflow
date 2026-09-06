#!/bin/bash

DECISION_DIR="$1"
MAPS_DIR="$DECISION_DIR/maps"

templatefile="@etcdir@/alert-email.tmpl"
subject="[RiverFlood] Alert Trigger"
mailinglist="$(< @etcdir@/alert.list)"
toaddress=$(paste -sd, <<< "$mailinglist")

boundary_mixed="0000$(date +%s%N)000"
boundary_alternate="111$(date +%s%N)1111"
boundary_related="10$(date +%s%N)10101"

declare -A report

while IFS=: read -r key value; do
    report["$key"]=$value
done < "$DECISION_DIR/summary/cagayan_activation_summary.txt"

attachments_file=$(mktemp)

trap 'rm -f "$attachments_file"' EXIT

render_attachments() {
	attachments=""
	shopt -s nullglob

	for file in "$MAPS_DIR"/*.{jpg,jpeg,png}; do
		mime=$(file --brief --mime-type "$file")
		data=$(base64 -w 0 "$file")

		attachments+=$'\n'
		attachments+="--$boundary_mixed"$'\n'
		attachments+="Content-Type: $mime"$'\n'
		attachments+="Content-Transfer-Encoding: base64"$'\n'
		attachments+="Content-Disposition: attachment; filename=\"$(basename "$file")\""$'\n'
		attachments+=$'\n'
		attachments+="$data"$'\n'
	done

	for csv_file in "$DECISION_DIR"/*.csv; do
		mime=$(file --brief --mime-type "$csv_file")
		data=$(base64 -w 0 "$csv_file")
		attachments+=$'\n'
		attachments+="--$boundary_mixed"$'\n'
		attachments+="Content-Type: $mime"$'\n'
		attachments+="Content-Transfer-Encoding: base64"$'\n'
		attachments+="Content-Disposition: attachment; filename=\"$(basename "$csv_file")\""$'\n'
		attachments+=$'\n'
		attachments+="$data"$'\n'
	done

	printf '%s' "$attachments" > "$attachments_file"
}

render() {
	render_attachments
	sed -f - "$templatefile" <<-EOF
		s/{{TO_ADDRESS}}/$toaddress/g
		s/{{SUBJECT}}/$subject/g
		s/{{BOUNDARY_MIXED}}/$boundary_mixed/g
		s/{{BOUNDARY_ALTERNATE}}/$boundary_alternate/g
		s/{{BOUNDARY_RELATED}}/$boundary_related/g
		s/{{RIVER_BASIN}}/${report[river_basin]}/g
		s/{{DATE}}/${report[date]}/g
		s/{{ACTIVATION_STATUS}}/${report[activation_status]}/g
		s/{{SEVERITY_LEVEL}}/${report[severity_level]}/g
		s/{{POPULATION_AFFECTED}}/${report[population_affected]}/g
		s/{{CERTAINTY}}/${report[certainty_level]}/g
		s/{{LEAD_TIME}}/${report[lead_time]}/g
		/{{ATTACHMENTS}}/{
			r $attachments_file
			d
		}
	EOF
}

msmtp -a default -t -- <<- EOF
	$(render)
EOF
