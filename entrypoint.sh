#!/bin/bash

set -euo pipefail

echo "current run $GITHUB_RUN_ID"
curl -i -u "$GITHUB_ACTOR:$GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs"
