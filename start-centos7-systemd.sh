#!/usr/bin/env bash

DOCKER_CONTAINER_DISTRO=centos7
DOCKER_CMD=/lib/systemd/systemd

EXEC_CMD="start-systemd-distro.sh ${DOCKER_CONTAINER_DISTRO} ${DOCKER_CMD}"
echo "${EXEC_CMD}"

${EXEC_CMD}
