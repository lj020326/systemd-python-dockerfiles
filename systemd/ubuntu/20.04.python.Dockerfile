## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/ubuntu2004-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2024041001"

# Set environment variables.
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC

ENV HOME="/root"
ENV PYTHON_VERSION="3.11.7"

## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://www.how2shout.com/linux/install-python-3-x-or-2-7-on-debian-11-bullseye-linux/
RUN apt-get update -y
#RUN apt-get install --no-install-recommends -y apt-utils sudo bash ca-certificates curl wget git tox
RUN apt-get install -y apt-utils \
    build-essential \
    sudo bash ca-certificates \
    curl wget git

## ref: https://stackoverflow.com/questions/75159821/installing-python-3-11-1-on-a-docker-container
## ref: https://stackoverflow.com/questions/63314253/how-to-install-python3-8-using-checkinstall-on-debian-10
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get -y install \
        libbz2-dev \
        libbz2-dev \
        libc6-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libnss3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev \
        xz-utils \
        tk-dev

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-ubuntu-systemd/blob/master/Dockerfile
## ref: https://stackoverflow.com/questions/4768446/i-cant-install-python-ldap
#RUN apt-get install -y libldap2-dev libsasl2-dev slapd ldap-utils

## ref: https://linodelinux.com/how-to-install-openssl-1-1-1-tls-1-3-on-centos-7/
#RUN cd /usr/src \
#    && wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz \
#    && tar -xzf openssl-1.1.1w.tar.gz \
#    && cd openssl-1.1*/ \
#    && ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl \
#    && make -j4 \
#    && make install \
#    && ldconfig
#
#RUN cd /usr/src \
#    && wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz \
#    && tar -xzf openssl-1.1.1w.tar.gz \
#    && cd openssl-1.1*/ \
#    && ./config shared --prefix=/usr/local \
#    && make install \
#    && ldconfig
#
#ENV LD_LIBRARY_PATH="$HOME/usr/local/lib:$LD_LIBRARY_PATH"
#
### ref: https://stackoverflow.com/questions/72133316/libssl-so-1-1-cannot-open-shared-object-file-no-such-file-or-directory
#RUN ln -s /usr/local/lib/libssl.so.1.1  /usr/lib/libssl.so.1.1 \
#    && ln -s /usr/local/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1

### ref: https://stackoverflow.com/questions/75159821/installing-python-3-11-1-on-a-docker-container
#RUN apt install software-properties-common -y
#RUN add-apt-repository "ppa:deadsnakes/ppa"
#RUN apt-get update -y
#RUN apt install python3.11 python3-pip -y

####################
## pyenv
#WORKDIR $HOME
#RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv
#ENV PYENV_ROOT="$HOME/.pyenv"

WORKDIR /
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git /pyenv

ENV PYENV_ROOT="/pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

## ref: https://github.com/pyenv/pyenv/issues/2416#issuecomment-1219484906
## ref: https://github.com/pyenv/pyenv/issues/2760#issuecomment-1868608898
## ref: https://stackoverflow.com/questions/57743230/userwarning-could-not-import-the-lzma-module-your-installed-python-is-incomple#57773679
## ref: https://superuser.com/questions/1346141/how-to-link-python-to-the-manually-compiled-openssl-rather-than-the-systems-one
## ref: https://github.com/pyenv/pyenv/issues/2416
#RUN env CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
#RUN env CPPFLAGS="-I/usr/include/openssl11/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
#RUN CPPFLAGS=$(pkg-config --cflags openssl) LDFLAGS=$(pkg-config --libs openssl) \
#RUN CPPFLAGS="-I/usr/local/openssl/include/openssl" \
#    LDFLAGS="-L/usr/lib/openssl -L/usr/local/openssl/lib" \
#    PYTHON_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/openssl" \
#    pyenv install $PYTHON_VERSION
#RUN CPPFLAGS="-I/usr/local/include/openssl" \
#    LDFLAGS="-L/usr/local/lib" \
#    pyenv install $PYTHON_VERSION
#RUN PYTHON_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/ssl" pyenv install $PYTHON_VERSION
RUN pyenv install $PYTHON_VERSION
#RUN pyenv global $PYTHON_VERSION
#RUN pyenv rehash
RUN eval "$(/pyenv/bin/pyenv init -)" && /pyenv/bin/pyenv local $PYTHON_VERSION

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]
#CMD ["/sbin/init", "--log-target=journal"]
##CMD ["/lib/systemd/systemd"]

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
