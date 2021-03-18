#!/bin/bash

set -euo pipefail

function runs {
    curl --header "authorization: Bearer $INPUT_GITHUB_TOKEN" \
        --header 'content-type: application/json' \
        --silent \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
}

set
echo "current run $GITHUB_RUN_ID"

echo "$(runs)"
#while [[ "$(runs | jq '[.check_runs[] | select(.status == "in_progress") .status] | length')" -ne 1 ]]; do
    #echo "Waiting for jobs to finish"
    #sleep 10
#done
