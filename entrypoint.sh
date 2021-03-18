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

if [[ "$(jq '.total_count - 1' $RUNS -r)" -ne "$(jq '[.check_runs[] | select(.conclusion != null and  .conclusion == "success") | .name] | length' /tmp/runs.json -r)" ]]; then
    echo 'Failure founds, exiting'
    exit 1
fi

PR=/tmp/pr.json

api "$(jq '.check_runs[0].pull_requests[0].url' $RUNS -r)" > $PR

jq '.labels' $PR
echo "label to check is ${INPUT_label:-}"

# shellcheck disable=SC2154
# shellcheck disable=SC2086
if [[ "$(jq '[.labels[] | select(.name == "'${INPUT_label:-}'")] | length' $PR)" == "1" ]]; then
    echo "Label not found - skipping automerge"
    exit 0
fi

echo "merging PR $(jq .url $PR -r )/merge -d '{\"merge_method\": \"${INPUT_merge_method:-}\"}'"
