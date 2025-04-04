#!/usr/bin/env bash

VERSION="2024.8.9"

REPO_PACKAGE_NAME=$1

#BASE_ARCH=$(rpm -E "%{_arch}")
#PACKAGE_DIR=/repos/Packages


#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
#  	echo -e "[ERROR]: ==> ${1}"
  	logMessage "${LOG_ERROR}" "${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
#  	echo -e "[WARN ]: ==> ${1}"
  	logMessage "${LOG_WARN}" "${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
#  	echo -e "[INFO ]: ==> ${1}"
  	logMessage "${LOG_INFO}" "${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
#  	echo -e "[TRACE]: ==> ${1}"
  	logMessage "${LOG_TRACE}" "${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
#  	echo -e "[DEBUG]: ==> ${1}"
  	logMessage "${LOG_DEBUG}" "${1}"
  fi
}
function abort() {
  logError "%s\n" "$@"
  exit 1
}

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  ## remove first item from FUNCNAME array
#  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2}")
  ## Get the length of the array
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")
#  echo "CALLING_FUNCTION_ARRAY[@]=${CALLING_FUNCTION_ARRAY[@]}"

  local CALL_ARRAY_LENGTH=${#CALLING_FUNCTION_ARRAY[@]}
  local REVERSED_CALL_ARRAY=()
  for (( i = CALL_ARRAY_LENGTH - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done
#  echo "REVERSED_CALL_ARRAY[@]=${REVERSED_CALL_ARRAY[@]}"

#  local CALLING_FUNCTION_STR="${CALLING_FUNCTION_ARRAY[*]}"
  ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
  local SEPARATOR=":"
  local CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  local CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  case "${LOG_MESSAGE_LEVEL}" in
    $LOG_ERROR*)
      LOG_LEVEL_STR="ERROR"
      ;;
    $LOG_WARN*)
      LOG_LEVEL_STR="WARN"
      ;;
    $LOG_INFO*)
      LOG_LEVEL_STR="INFO"
      ;;
    $LOG_TRACE*)
      LOG_LEVEL_STR="TRACE"
      ;;
    $LOG_DEBUG*)
      LOG_LEVEL_STR="DEBUG"
      ;;
    *)
      abort "Unknown LOG_MESSAGE_LEVEL of [${LOG_MESSAGE_LEVEL}] specified"
  esac

  local LOG_LEVEL_PADDING_LENGTH=5
  local PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  LOG_LEVEL_STR=$1

  case "${LOG_LEVEL_STR}" in
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
      ;;
    *)
      abort "Unknown LOG_LEVEL_STR of [${LOG_LEVEL_STR}] specified"
  esac

}

function abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

## ref: https://unix.stackexchange.com/questions/50642/download-all-dependencies-with-yumdownloader-even-if-already-installed
## ref: https://stackoverflow.com/questions/635869/can-yum-tell-me-which-of-my-repositories-provide-a-particular-package
## ref: https://www.cyberciti.biz/faq/yum-download-source-packages-from-rhn/
## ref: https://www.thegeekstuff.com/2015/02/rpm-build-package-example/
## ref: https://blog.packagecloud.io/working-with-source-rpms/
function download_and_build_package_source() {

  local REPO_PACKAGE_NAME=$1

  ## yum list readline
  logInfo "==============================="
  logInfo "installing ${REPO_PACKAGE_NAME}"
  yumdownloader --source "${REPO_PACKAGE_NAME}"
  REPO_FILE=$(find ${REPO_PACKAGE_NAME}*rpm)

  #repotrack -a "${BASE_ARCH}" -p "${PACKAGE_DIR}" "${REPO_PACKAGE_NAME}"
  #REPO_FILE=$(find ${PACKAGE_DIR}/${REPO_PACKAGE_NAME}*${BASE_ARCH}*rpm)

  rpm -ivh "${REPO_FILE}"

  BUILDDEP_CMD="yum-builddep ${REPO_PACKAGE_NAME}"
  logInfo "${BUILDDEP_CMD}"
  eval "${BUILDDEP_CMD}"

#  BUILD_CMD="rpmbuild -ba ${HOME}/rpmbuild/SPECS/${REPO_PACKAGE_NAME}.spec"
  BUILD_CMD="rpmbuild --quiet -ba ${HOME}/rpmbuild/SPECS/${REPO_PACKAGE_NAME}.spec > /dev/null 2>&1"
  logInfo "${BUILD_CMD}"
  eval "${BUILD_CMD}"

#  REPO_RPM_FILE=$(find ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}-[0-9]*rpm)
#  REPO_DEVEL_RPM_FILE=$(find ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}-devel-[0-9]*rpm)
#
#  YUM_CMD_INSTALL_PACKAGE_RPM="yum install -y ${REPO_RPM_FILE}"
#  YUM_CMD_INSTALL_PACKAGE_DEVEL_RPM="yum install -y ${REPO_DEVEL_RPM_FILE}"

  YUM_CMD_INSTALL_PACKAGE_RPM="yum install -y ${HOME}/rpmbuild/RPMS/x86_64/${REPO_PACKAGE_NAME}*rpm"

  logInfo "${YUM_CMD_INSTALL_PACKAGE_RPM}"
  eval "${YUM_CMD_INSTALL_PACKAGE_RPM}"

  logInfo "finished installing ${REPO_PACKAGE_NAME}"
  logInfo "==============================="
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
