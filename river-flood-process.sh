#!/bin/bash

set -e

BASE_DIR=/opt/river-flood-workflow
RUN_SPEC="$BASE_DIR/config/run_specs/daily_monitoring.yaml"
BASINS=cagayan

GLOFAS_CACHE=/var/cache/glofas
latest=$(
	for d in "$GLOFAS_CACHE"/*; do
		[[ -d "$d" ]] || continue
		printf '%s\n' "${d##*/}"
	done | sort | tail -n1
)

date=$(date -d "$latest" '+%Y-%m-%d')

"$BASE_DIR"/.venv/bin/flood-monitoring \
	--run-spec "$RUN_SPEC" \
	--basins "$BASINS" \
	--date "$date"

DECISION_DIR="$BASE_DIR/data/gold/trigger_decisions/$date"
DECISION_FILE="$DECISION_DIR/decision.txt"
if [[ -f "$DECISION_FILE" ]]; then
	DECISION=$(< "$DECISION_FILE")
else
	echo 'No alert requested.'
	DECISION=""
fi

if [[ "$DECISION" == "triggered=True" ]]; then
	echo 'Alert triggered! Sending out alert via email.'
	/usr/bin/river-flood-alert "$DECISION_DIR"
fi
