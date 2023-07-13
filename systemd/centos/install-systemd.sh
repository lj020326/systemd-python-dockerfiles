#!/bin/bash

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd

yum groupinstall -y "Development Tools"
yum install -y libcap-devel gperf glib2-devel python3-pip jq

export PIP_ROOT_USER_ACTION=ignore
pip3 install --user meson
pip3 install ninja
pip3 install jinja2

## ref: https://stackoverflow.com/questions/18384873/how-to-list-the-releases-of-a-repository
TARBALL_URL=$(curl -fsSL https://api.github.com/repos/systemd/systemd/releases/latest | jq -r '.tarball_url')

#RELEASE_VERSION=$(echo "$TARBALL_URL" | cut -d'/' -f8)
RELEASE_VERSION=$(echo "$TARBALL_URL" | sed 's|.*\/v\([0-9]\+\)|\1|')
TARBALL_FILE="v${RELEASE_VERSION}.tar.gz"

curl -fsSL "${TARBALL_URL}" -o "/tmp/${TARBALL_FILE}"

tar -xf "/tmp/${TARBALL_FILE}" --directory "/tmp/systemd-source"

#cd "/tmp/systemd-${RELEASE_VERSION}"
cd "/tmp/systemd-source"

./configure

#make
