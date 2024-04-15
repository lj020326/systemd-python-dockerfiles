ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/debian8-systemd:latest
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
RUN apt-get update && \
    apt-get install --no-install-recommends -y apt-utils sudo bash ca-certificates curl wget git tox

## ref: https://stackoverflow.com/questions/75159821/installing-python-3-11-1-on-a-docker-container
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get -y install build-essential \
        libbz2-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libnss3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev

    ## ref: https://stackoverflow.com/questions/60775172/pyenvs-python-is-missing-bzip2-module
RUN apt-get install -y libncursesw5-dev xz-utils tk-dev

## MUST install devel libs for python-ldap to work
#RUN apt-get install -y libldap2-dev libsasl2-dev slapd ldap-utils

#RUN cd /usr/src \
#    && wget -q https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz \
#    && tar -xzf Python-3.11.7.tgz \
#    && cd Python-3.11.7 \
#    && export DEBIAN_FRONTEND=noninteractive \
#    && ./configure --enable-optimizations \
#    && make altinstall
#
#RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1
#
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
## ref: https://github.com/pyenv/pyenv/issues/2416
#RUN env CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
#RUN env CPPFLAGS="-I/usr/include/openssl11/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
#RUN CPPFLAGS=$(pkg-config --cflags openssl) LDFLAGS=$(pkg-config --libs openssl) \
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
