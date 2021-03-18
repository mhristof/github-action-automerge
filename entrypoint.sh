#!/bin/bash

set -euo pipefail

set
echo "current run $GITHUB_RUN_ID"
echo "${INPUT_JOB}"
curl --header "authorization: Bearer $INPUT_GITHUB_TOKEN" \
        --header 'content-type: application/json' \
        -i \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
