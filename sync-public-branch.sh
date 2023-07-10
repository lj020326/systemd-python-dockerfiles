#!/usr/bin/env bash

GIT_DEFAULT_BRANCH=master
GIT_REMOTE_PUBLIC=github

## ref: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

echo "Push to public repo:"
git push "${GIT_REMOTE_PUBLIC}" "${GIT_DEFAULT_BRANCH}"
