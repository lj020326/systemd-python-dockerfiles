#!/usr/bin/env bash
#
# helper to correctly do an 'apt-get install' inside a Dockerfile's RUN
# the upstream mirror seems to fail a lot so this will retry 5 times
#
# source: https://github.com/WyseNynja/dockerfile-debian/blob/jessie/docker-apt-install.sh
#

set -e

function apt-install {
    apt-get install --no-install-recommends -y "$@"
}

function retry {
    # inspired by:
    # http://unix.stackexchange.com/questions/82598/how-do-i-write-a-retry-logic-in-script-to-keep-retrying-to-run-it-upto-5-times
    local n=1
    local max=5
    local delay=5
    while true; do
        echo "Attempt ${n}/${max}: $@"
        "$@"
        local exit_code=$?

        if [ "$exit_code" -eq 0 ]; then
            echo "Attempt ${n}/${max} was successful"
            break
        elif [[ $n -lt $max ]]; then
            echo "Attempt ${n}/${max} exited non-zero ($exit_code)"
            ((n++))
            echo "Sleeping $delay seconds..."
            sleep $delay;
        else
            echo "Attempt ${n}/${max} exited non-zero ($exit_code). Giving up"
            return $exit_code
        fi
    done
}

export DEBIAN_FRONTEND=noninteractive

# stop apt from starting processes on install
# /usr/sbin/policy-rc.d is setup to exit 101 by upstream
export RUNLEVEL=1

echo "apt-key update:"
apt-key update 2>&1

echo
echo "apt-get update:"
apt-get update

echo
echo "Downloading packages..."
retry apt-install --download-only "$@" || true

echo
echo "Installing packages..."
apt-install "$@"

echo
echo "Cleaning up..."
rm -rf /var/lib/apt/lists/* \
    /var/log/alternatives.log \
    /var/log/apt/history.log \
    /var/log/apt/term.log \
    /var/log/dpkg.log \
    /var/tmp/* \
    /tmp/*

# docker's official debian and ubuntu images do apt-get clean for us
