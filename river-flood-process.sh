#!/bin/bash

set -e

BASE_DIR=/opt/river-flood-workflow
RUN_SPEC="$BASE_DIR/config/run_specs/daily_monitoring_etl.yaml"
BASINS=cagayan

uv run flood-monitoring \
    --run-spec "$RUN_SPEC" \
    --basins "$BASINS"

DATE=$(date '+%Y-%m-%d')
DECISION_DIR="$BASE_DIR/data/gold/trigger_decisions/$DATE"
DECISION=$(< "$DECISION_DIR/decision.txt")

if [[ "$DECISION" == "triggered=True" ]]; then
	echo 'Alert triggered! Sending out alert via email.'
	/usr/bin/river-flood-alert "$DECISION_DIR"
fi
