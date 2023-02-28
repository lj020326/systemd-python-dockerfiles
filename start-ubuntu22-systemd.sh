#!/usr/bin/env bash

DOCKER_CONTAINER_DISTRO=ubuntu2204

EXEC_CMD="start-systemd-distro.sh ${DOCKER_CONTAINER_DISTRO}"
echo "${EXEC_CMD}"

${EXEC_CMD}
