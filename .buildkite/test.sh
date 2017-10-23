#!/bin/bash

set -eo pipefail
echo "--- Copy Templates"
cp -v src/config/loggly.js.sample src/config/loggly.js
echo "--- Test"
if [[ "$BUILDKITE_BRANCH" == "master"  ]]; then
export NODE_ENV=prod
fi
npm install
if [[ "$BUILDKITE_BRANCH" == "master"  ]]; then
export NODE_ENV=production
fi
npm run build
npm run test
if [ $BUILDKITE_PULL_REQUEST = false ]; then
    echo "--- Sonar Scanner: Scanning "$BUILDKITE_BRANCH" branch"
    sonar-scanner
else
    echo "--- Sonar Scanner: Scanning pull request on "$BUILDKITE_BRANCH" branch"
    sonar-scanner -Dsonar.analysis.mode=preview   -Dsonar.github.pullRequest=$BUILDKITE_PULL_REQUEST  -Dsonar.github.oauth=$GITHUB_ACCESS_TOKEN | tee bk-pipeline.log
fi