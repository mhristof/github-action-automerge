#!/bin/bash

set -euo pipefail

function runs {
    curl --header "authorization: Bearer $INPUT_GITHUB_TOKEN" \
        --header 'content-type: application/json' \
        --silent \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
}

while [[ "$(runs | tee /tmp/runs.json | jq '[.check_runs[] | select(.status == "in_progress") .status] | length')" -ne 1 ]]; do
    echo "Waiting for jobs to finish"
    jq '.check_runs[] | select(.status == "in_progress") .name' /tmp/runs.json -r
    sleep 10
done

runs

if [[ "$(jq '.total_count - 1' /tmp/runs.json -r)" -ne "$(jq '[.check_runs[] | select(.conclusion != null and  .conclusion == "success") | .name] | length' /tmp/runs.json -r)" ]]; then
    exit 1
fi
