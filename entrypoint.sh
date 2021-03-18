#!/bin/bash

set -euo pipefail

set
echo "current run $GITHUB_RUN_ID"
curl --header "authorization: Bearer $GINPUT_GITHUB_TOKEN" \
        --header 'content-type: application/json' \
        -i \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
