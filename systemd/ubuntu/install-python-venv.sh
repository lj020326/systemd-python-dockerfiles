#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_OS=$(uname -s | tr "[:upper:]" "[:lower:]")

# Python 3
#PYTHON_VERSION_DEFAULT="3.9.7"
#PYTHON_VERSION_DEFAULT=3.10.9
#PYTHON_VERSION_DEFAULT=3.11.9
PYTHON_VERSION_DEFAULT=3.12.9

## source: https://gist.github.com/simonkuang/14abf618f631ba3f0c7fee7b4ea3f214
#PYTHON3_RH_LIBS=epel-release
#PYTHON3_RH_LIBS="gcc gcc-c++ glibc glibc-devel curl git libffi-devel sqlite-devel bzip2-devel bzip2 readline-devel"
#PYTHON3_RH_LIBS="zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel"
##PYTHON3_RH_LIBS="zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel"
#PYTHON3_RH_LIBS="python3-devel readline-devel bzip2-devel libffi-devel ncurses-devel sqlite-devel"
#PYTHON3_RH_LIBS="readline-devel bzip2-devel libffi-devel ncurses-devel sqlite-devel openssl-devel"
PYTHON3_RH_LIBS="bzip2-devel krb5-devel libffi-devel ncurses-devel openssl-devel readline-devel sqlite-devel xz-devel zlib-devel"

PYTHON3_DEB_LIBS="libreadline-dev libbz2-dev libffi-dev libncurses-dev libsqlite3-dev liblzma-dev libssl-dev"

## ref: https://github.com/pyenv/pyenv/issues/281
## ref: https://discuss.python.org/t/build-python3-11-5-with-static-openssl-and-libffi-on-centos7/37485/5
## ref: https://serverfault.com/questions/973470/in-centos-what-does-the-line-ld-library-path-usr-local-lib-usr-local-lib64-do
## ref: https://github.com/pyenv/pyenv/issues/2416#issuecomment-1219484906
## ref: https://github.com/pyenv/pyenv/issues/2760#issuecomment-1868608898
## ref: https://stackoverflow.com/questions/57743230/userwarning-could-not-import-the-lzma-module-your-installed-python-is-incomple#57773679
## ref: https://superuser.com/questions/1346141/how-to-link-python-to-the-manually-compiled-openssl-rather-than-the-systems-one
## ref: https://github.com/pyenv/pyenv/issues/2416
CPPFLAGS_DEFAULT="-I/usr/include/openssl"
LDFLAGS_DEFAULT="-L/usr/lib64/openssl -lssl -lcrypto"
CFLAGS_DEFAULT="-fPIC"
#LD_LIBRARY_PATH_DEFAULT="/usr/lib:/usr/lib64"
#PKG_CONFIG_PATH_DEFAULT="/usr/lib64/pkgconfig"


function setup_pyenv_linux() {

#  if [[ -n "$(command -v dnf)" ]]; then
#    sudo dnf install -y "${PYTHON3_RH_LIBS}"
#  elif [[ -n "$(command -v yum)" ]]; then
#    sudo yum install -y "${PYTHON3_RH_LIBS}"
#  elif [[ -n "$(command -v apt-get)" ]]; then
#    sudo apt-get install -y "${PYTHON3_DEB_LIBS}"
#  fi

  PYENV_BIN_DIR="${PYENV_ROOT}/bin"
  PYENV_BIN="${PYENV_BIN_DIR}/pyenv"

  mkdir -p "${PYENV_ROOT}"
  git clone --depth=1 https://github.com/pyenv/pyenv.git "${PYENV_ROOT}"

}


function setup_pyenv_msys2() {
#  # ref: https://dev.to/taijidude/execute-a-powershell-script-from-inside-the-git-bash-1enj
#  powershell -File files\\scripts\\python\\pyenv-install.ps1
  PYENV_INSTALL_SCRIPT="${SCRIPT_DIR}/pyenv-install.ps1"
  eval "powershell.exe -noprofile -executionpolicy bypass -file ${PYENV_INSTALL_SCRIPT}"

  PYENV_ROOT="${HOME}/.pyenv/pyenv-win"
  PYENV_BIN_DIR="${PYENV_ROOT}/bin"

#  PYENV_IN_BASHENV=$(grep -c "pyenv init" ${HOME}/.bashrc)

  export PATH="${PYENV_BIN_DIR}:${PATH}"

}

function main() {

  PYTHON_VERSION=${1-"${PYTHON_VERSION_DEFAULT}"}
  PYENV_ROOT="${2:-/opt/pyenv}"

  case "${PLATFORM_OS}" in
    linux*)
      INSTALL_ON_LINUX=1
      ;;
    darwin*)
      INSTALL_ON_MACOS=1
      ;;
    cygwin* | mingw64* | mingw32* | msys*)
      INSTALL_ON_MSYS=1
      ;;
    *)
      abort "Install script is only supported on macOS, Linux and msys2."
      ;;
  esac

  ## ref: https://www.pythonpool.com/fixed-modulenotfounderror-no-module-named-_bz2/
  ## ref: https://stackoverflow.com/questions/27022373/python3-importerror-no-module-named-ctypes-when-using-value-from-module-mul#48045929
  if [[ -n "${INSTALL_ON_LINUX-}" ]]; then
    setup_pyenv_linux
  fi
  if [[ -n "${INSTALL_ON_MACOS-}" ]]; then
    ## ref: https://github.com/pyenv/pyenv/issues/2143
    brew install gcc make
    brew install pyenv
  fi
  if [[ -n "${INSTALL_ON_MSYS-}" ]]; then
    setup_pyenv_msys2
  fi

  if [ -z "$CPPFLAGS" ]; then
    export CPPFLAGS="${CPPFLAGS_DEFAULT}"
  fi
  if [ -z "$LDFLAGS" ]; then
    export LDFLAGS="${LDFLAGS_DEFAULT}"
  fi
  if [ -z "$CFLAGS" ]; then
    export CFLAGS="${CFLAGS_DEFAULT}"
  fi
  #if [ -z "$LD_LIBRARY_PATH" ]; then
  #  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH_DEFAULT}"
  #fi
  #if [ -z "$PKG_CONFIG_PATH" ]; then
  #  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH_DEFAULT}"
  #fi

  ## view all exported library variables
  export -p | grep -e LD_LIBRARY_PATH -e PKG_CONFIG_PATH -e CPPFLAGS -e LDFLAGS -e CFLAGS

  export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

  eval "${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION}"
  #eval "${PYENV_ROOT}/bin/pyenv global ${PYTHON_VERSION}"
  #pyenv rehash
  eval "${PYENV_ROOT}/bin/pyenv init -"
  eval "${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION}"

}

main "$@"
