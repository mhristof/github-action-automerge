#!/bin/bash

set -euo pipefail

function api {
    local url
    url=$1

    curl --header "authorization: Bearer $INPUT_GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        --header 'content-type: application/json' \
        --silent "$url"
    }

function runs {
    api "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
}

RUNS=/tmp/runs.json

while [[ "$(runs | tee $RUNS | jq '[.check_runs[] | select(.status == "in_progress") .status] | length')" -ne 1 ]]; do
    echo "Waiting for jobs to finish"
    jq '.check_runs[] | select(.status == "in_progress") .name' $RUNS -r
    sleep 10
done

cat $RUNS

if [[ "$(jq '.total_count - 1' $RUNS -r)" -ne "$(jq '[.check_runs[] | select(.conclusion != null and  .conclusion == "success") | .name] | length' /tmp/runs.json -r)" ]]; then
    echo 'Failure founds, exiting'
    exit 1
fi


if [[ "$(api "$(jq '.check_runs[0].pull_requests[0].url' $RUNS -r)" | jq '.labels | index( "automerge" )')" != "null" ]]; then
    echo "merging PR"
fi
