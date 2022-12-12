#!/bin/bash

## source: https://stackoverflow.com/questions/43606854/install-fresh-copies-of-centos-7-base-repos

install-centos-release() {
 releasever="$(rpm -q --qf '%{VERSION}' "$(rpm -q --whatprovides centos-release)")" \
 && releasever="$(printf "%s" "$releasever" | sed -e 's/\..*$//g')" \
 && basearch="$(uname -m)" \
 && reposurl=$(printf "%s" "http://mirror.centos.org/centos/$releasever/os/$basearch/Packages/") \
 && releaserpm=$(curl --silent "$reposurl" | grep -oP '(?<=")centos-release.*.rpm(?=")') \
 && releaseuri=$(printf "%s%s" "$reposurl" "$releaserpm") \
 && rpm -Uvh --force "$releaseuri"
}

# Either launch a new terminal and copy `install-centos-release` into the current shell process,
# or create a shell script and add it to the PATH to enable command invocation with bash.

install-centos-release

# Refresh YUM repository(ies)
yum clean all
yum -y update
