#!/bin/ash

## ref: https://github.com/peteyoung/docker-alpine-pyenv

# install man
apk add man man-pages mdocml-apropos less less-doc
export PAGER=less

# install bash
apk add bash bash-doc bash-completion

# install curl
apk add curl curl-doc

# install git
apk add git git-doc

# install gcc and some libs
apk add build-base gcc-doc

# explicitly install patch (the one with Alpine's build-base doesn't support force) to fix: patch: unrecognized option: force
apk add patch

# install zlib source to fix: zipimport.ZipImportError: can't decompress data; zlib not available
apk add zlib-dev

# install libffi source to fix: ModuleNotFoundError: No module named '_ctypes'
apk add libffi-dev

# install linux headers to fix: ModuleNotFoundError: No module named '_socket'
apk add linux-headers

# install readline source to fix: WARNING: The Python readline extension was not compiled. Missing the GNU readline lib?
apk add readline-dev

# install openssl and source to fix: ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?
apk add openssl openssl-dev

# install sqlite source to fix: WARNING: The Python sqlite3 extension was not compiled. Missing the SQLite3 lib?
apk add sqlite-dev

# install bzip source to fix: WARNING: The Python bz2 extension was not compiled. Missing the bzip2 lib?
apk add bzip2-dev

# install pyenv pyenv-doctor pyenv-installer pyenv-update pyenv-virtualenv pyenv-which-ext
curl https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
