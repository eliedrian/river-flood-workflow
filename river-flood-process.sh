#!/bin/bash

set -e

date=$(date '+%Y-%m-%d')
cache_dir=@cachedir@/glofas

args=()
while [ $# -gt 0 ]; do
  case $1 in
    --cache-dir) cache_dir=$2; shift 2 ;;
	--date) date=$2; shift 2 ;;
    --) shift; args+=("$@"); break ;;
    *)  args+=("$1"); shift ;;
  esac
done
set -- "${args[@]}"

RUN_SPEC="$BASE_DIR/config/run_specs/daily_monitoring.yaml"
BASINS=(cagayan bicol)

"$BASE_DIR"/.venv/bin/flood-monitoring \
	--run-spec "$RUN_SPEC" \
	--basins "${BASINS[@]}" \
	--date "$date"

DECISION_DIR="$BASE_DIR/data/gold/trigger_decisions/$date"
DECISION_FILE="$DECISION_DIR/decision.txt"
activation_file=("$DECISION_DIR/activation_$date*.csv")
activation_file=${activation_file[0]}
if [[ -f "$DECISION_FILE" ]]; then
	DECISION=$(< "$DECISION_FILE")
else
	echo 'No alert requested.'
	DECISION=""
fi

if [[ "$DECISION" == "triggered=True" ]]; then
	echo 'Alert triggered! Sending out alert via email.'
	@bindir@/csv-activation "$activation_file"
	@bindir@/river-flood-alert "$DECISION_DIR"
fi
