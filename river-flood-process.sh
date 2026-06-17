#!/bin/bash

BASE_DIR=/opt/river-flood-workflow
RUN_SPEC="$BASE_DIR/config/run_specs/daily_monitoring_etl.yaml"
BASINS=cagayan

uv run flood-monitoring \
    --run-spec "$RUN_SPEC" \
    --basins "$BASINS"
