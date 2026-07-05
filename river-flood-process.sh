#!/bin/bash

set -e

BASE_DIR=/opt/river-flood-workflow
RUN_SPEC="$BASE_DIR/config/run_specs/daily_monitoring_etl.yaml"
BASINS=cagayan

if [[ -n "${DEBUG:-}" ]]; then
	date=$(date -d yesterday '+%Y-%m-%d')
else
	date=$(date '+%Y-%m-%d')
fi

/usr/bin/env uv run flood-monitoring \
	--run-spec "$RUN_SPEC" \
	--basins "$BASINS" \
	--date "$date"

DECISION_DIR="$BASE_DIR/data/gold/trigger_decisions/$date"
DECISION=$(< "$DECISION_DIR/decision.txt")

if [[ "$DECISION" == "triggered=True" ]]; then
	echo 'Alert triggered! Sending out alert via email.'
	/usr/bin/river-flood-alert "$DECISION_DIR"
fi
