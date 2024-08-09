#!/usr/bin/env bash

VERSION="2024.8.9"

REPO_PACKAGE_NAME=$1

#BASE_ARCH=$(rpm -E "%{_arch}")
#PACKAGE_DIR=/repos/Packages

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ==> ${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	echo -e "[WARN ]: ==> ${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	echo -e "[INFO ]: ==> ${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ==> ${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ==> ${1}"
  fi
}

function setLogLevel() {
  local LOGLEVEL=$1

  case "${LOGLEVEL}" in
    ERROR*)
      LOG_LEVEL=$LOG_ERROR
      ;;
    WARN*)
      LOG_LEVEL=$LOG_WARN
      ;;
    INFO*)
      LOG_LEVEL=$LOG_INFO
      ;;
    TRACE*)
      LOG_LEVEL=$LOG_TRACE
      ;;
    DEBUG*)
      LOG_LEVEL=$LOG_DEBUG
      DISPLAY_TEST_RESULTS=1
      ;;
    *)
      abort "Unknown loglevel of [${LOGLEVEL}] specified"
  esac

}


function download_and_build_package_source() {
  local LOG_PREFIX="download_and_build_package_source():"
  local REPO_PACKAGE_NAME=$1

  ## yum list readline
  logInfo "${LOG_PREFIX} ==============================="
  logInfo "${LOG_PREFIX} installing ${REPO_PACKAGE_NAME}"
  yumdownloader --source "${REPO_PACKAGE_NAME}"
  REPO_FILE=$(find ${REPO_PACKAGE_NAME}*rpm)

  #repotrack -a "${BASE_ARCH}" -p "${PACKAGE_DIR}" "${REPO_PACKAGE_NAME}"
  #REPO_FILE=$(find ${PACKAGE_DIR}/${REPO_PACKAGE_NAME}*${BASE_ARCH}*rpm)

  rpm -ivh "${REPO_FILE}"

  BUILDDEP_CMD="yum-builddep ${REPO_PACKAGE_NAME}"
  logInfo "${LOG_PREFIX} ${BUILDDEP_CMD}"
  eval "${BUILDDEP_CMD}"

#  BUILD_CMD="rpmbuild -ba ${HOME}/rpmbuild/SPECS/${REPO_PACKAGE_NAME}.spec"
  BUILD_CMD="rpmbuild --quiet -ba ${HOME}/rpmbuild/SPECS/${REPO_PACKAGE_NAME}.spec > /dev/null 2>&1"
  logInfo "${LOG_PREFIX} ${BUILD_CMD}"
  eval "${BUILD_CMD}"

#  REPO_RPM_FILE=$(find ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}-[0-9]*rpm)
#  REPO_DEVEL_RPM_FILE=$(find ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}-devel-[0-9]*rpm)
#
#  YUM_CMD_INSTALL_PACKAGE_RPM="yum install -y ${REPO_RPM_FILE}"
#  YUM_CMD_INSTALL_PACKAGE_DEVEL_RPM="yum install -y ${REPO_DEVEL_RPM_FILE}"

  YUM_CMD_INSTALL_PACKAGE_RPM="yum install -y ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}*rpm"

  logInfo "${LOG_PREFIX} ${YUM_CMD_INSTALL_PACKAGE_RPM}"
  eval "${YUM_CMD_INSTALL_PACKAGE_RPM}"

  logInfo "${LOG_PREFIX} finished installing ${REPO_PACKAGE_NAME}"
  logInfo "${LOG_PREFIX} ==============================="
}


function usage() {
  echo "Usage: ${0} [options] [[package_name] [package_name] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -v : show script version"
  echo "       -k : keep temp directory/files"
  echo "       -h : help"
  echo "     [TEST_CASES]"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} readline"
	echo "       ${0} readline bzip2"
	echo "       ${0} -L DEBUG readline"
  echo "       ${0} -v"
	[ -z "$1" ] || exit "$1"
}


function main() {

  while getopts "L:vh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  if [ $# -eq 0 ]; then
    logError "must specify package name(s) to download source and install"
    usage 1
  fi
  PACKAGE_LIST=("$@")

  logInfo "PACKAGE_LIST=${PACKAGE_LIST[*]}"

  for PACKAGE_NAME in "${PACKAGE_LIST[@]}"; do
    logInfo "Installing PACKAGE_NAME => ${PACKAGE_NAME}"
    download_and_build_package_source "${PACKAGE_NAME}"
  done
}

main "$@"
