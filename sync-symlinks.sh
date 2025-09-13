#!/usr/bin/env bash

BUILD_DIR_LIST=("aports-dev")
BUILD_DIR_LIST+=("openrc/alpine")
BUILD_DIR_LIST+=("systemd/centos")
BUILD_DIR_LIST+=("systemd/debian")
BUILD_DIR_LIST+=("systemd/fedora")
BUILD_DIR_LIST+=("systemd/redhat")
BUILD_DIR_LIST+=("systemd/ubuntu")

PROJECT_DIR="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel)"
SCRIPT_DIRECTORY="${PROJECT_DIR}/scripts"

## ref: https://unix.stackexchange.com/questions/573047/how-to-get-the-relative-path-between-two-directories
function pnrelpath() {
  ## get the relative path between two directories
  set -- "${1%/}/" "${2%/}/" ''               ## '/'-end to avoid mismatch
  while [ "$1" ] && [ "$2" = "${2#"$1"}" ]    ## reduce $1 to shared path
  do  set -- "${1%/?*/}/"  "$2" "../$3"       ## source/.. target ../relpath
  done
  REPLY="${3}${2#"$1"}"                       ## build result
  # unless root chomp trailing '/', replace '' with '.'
  [ "${REPLY#/}" ] && REPLY="${REPLY%/}" || REPLY="${REPLY:-.}"
  echo "${REPLY}"
}

function sync_symlinks() {
  BUILD_DIR_LIST=("$@")
  local LOG_PREFIX="==> sync_symlinks():"

  for BUILD_DIR in "${BUILD_DIR_LIST[@]}"; do
    echo "BUILD_DIR=${BUILD_DIR}"
    local BUILD_PATH="${PROJECT_DIR}/${BUILD_DIR}"
    cd "${BUILD_PATH}"
    RELPATH=$(pnrelpath "$PWD" "$SCRIPT_DIRECTORY")
    echo "${LOG_PREFIX} RELPATH=${RELPATH}"
    ln -sf "${RELPATH}" ./
  done
}

function main() {
    sync_symlinks "${BUILD_DIR_LIST[@]}"
}

main "$@"
