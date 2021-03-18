#!/bin/bash

set -euo pipefail
set -x

die() { echo "$*" 1>&2 ; exit 1; }

# args:
# $1: the url to curl
# $2: method, defaults to GET
# $3: data, defaults to '{}'
function api {
    local url
    local method
    local data
    url=$1
    method="${2:-GET}"
    data="${3:-'{}'}"

    curl --header "authorization: Bearer $INPUT_GITHUB_TOKEN" \
        -X "$method" \
        -H "Accept: application/vnd.github.v3+json" \
        --header 'content-type: application/json' \
        -d "$data" \
        --silent "$url"
    }

function runs {
    api "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
}

RUNS=/tmp/runs.json
PR=/tmp/pr.json

while [[ "$(runs | tee $RUNS | jq '[.check_runs[] | select(.status == "in_progress") .status] | length')" -ne 1 ]]; do
    echo "Waiting for jobs to finish"
    jq '.check_runs[] | select(.status == "in_progress") .name' $RUNS -r
    sleep 10
done

if [[ "$(jq '.total_count - 1' $RUNS -r)" -ne "$(jq '[.check_runs[] | select(.conclusion != null and  .conclusion == "success") | .name] | length' /tmp/runs.json -r)" ]]; then
    echo 'Failure founds, exiting'
    exit 1
fi

api "$(jq '.check_runs[0].pull_requests[0].url' $RUNS -r)" > $PR

# shellcheck disable=SC2154
# shellcheck disable=SC2086
if [[ "$(jq '[.labels[] | select(.name == "'${INPUT_LABEL:-}'")] | length' $PR)" != "1" ]]; then
    echo "Label not found - skipping automerge"
    exit 0
fi

case "${INPUT_MERGE_METHOD:-}" in
    merge|squash|rebase)
        :
        ;;
    *) die "Error, unknown merge method $INPUT_MERGE_METHOD";;
esac

api "$(jq .url $PR -r )/merge" "PUT" "{\"merge_method\": \"${INPUT_MERGE_METHOD:-}\"}"
