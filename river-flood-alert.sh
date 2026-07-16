#!/bin/bash

DECISION_DIR="$1"
MAPS_DIR="$DECISION_DIR/maps"

templatefile="/etc/river-flood-workflow/alert-email.tmpl"
subject="[RiverFlood] Alert Trigger"
mailinglist="$(< /etc/river-flood-workflow/alert.list)"
toaddress="$(paste -sd, <<< "$mailinglist")"

boundary="0000$(date +%s%N)000"

attachments_file=$(mktemp)

trap 'rm -f "$attachments_file"' EXIT

render_attachments() {
	attachments=""
	shopt -s nullglob

	for file in "$MAPS_DIR"/*.{jpg,jpeg,png}; do
		mime=$(file --brief --mime-type "$file")
		data=$(base64 -w 0 "$file")

		attachments+=$'\n'
		attachments+="--$boundary"$'\n'
		attachments+="Content-Type: $mime"$'\n'
		attachments+="Content-Transfer-Encoding: base64"$'\n'
		attachments+="Content-Disposition: attachment; filename=\"$(basename "$file")\""$'\n'
		attachments+=$'\n'
		attachments+="$data"$'\n'
	done

	decision_csv=("$DECISION_DIR"/trigger_decisions_*.csv)
	mime=$(file --brief --mime-type "$decision_csv")
	data=$(base64 -w 0 "$decision_csv")
	attachments+=$'\n'
	attachments+="--$boundary"$'\n'
	attachments+="Content-Type: $mime"$'\n'
	attachments+="Content-Transfer-Encoding: base64"$'\n'
	attachments+="Content-Disposition: attachment; filename=\"$(basename "$file")\""$'\n'
	attachments+=$'\n'
	attachments+="$data"$'\n'

	printf '%s' "$attachments" > "$attachments_file"
}

render() {
	render_attachments
	sed -f - "$templatefile" <<-EOF
		s/{{TO_ADDRESS}}/$toaddress/g
		s/{{SUBJECT}}/$subject/g
		s/{{BOUNDARY}}/$boundary/g
		/{{ATTACHMENTS}}/{
			r '"$attachments_file"'
			d
		}
	EOF
}

msmtp -a default -t -- <<- EOF
	"$(render)"
EOF
