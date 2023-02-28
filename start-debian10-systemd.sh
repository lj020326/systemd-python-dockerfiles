#!/usr/bin/env bash

DOCKER_CONTAINER_DISTRO=debian10

EXEC_CMD="start-systemd-distro.sh ${DOCKER_CONTAINER_DISTRO}"
echo "${EXEC_CMD}"

${EXEC_CMD}
