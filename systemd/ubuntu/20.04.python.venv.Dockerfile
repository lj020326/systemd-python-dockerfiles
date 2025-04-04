## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/ubuntu2004-systemd:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

## versions at https://www.python.org/ftp/python/
#ARG PYTHON_VERSION="3.11.9"
ARG PYTHON_VERSION="3.12.9"
#ARG PYENV_ROOT="/pyenv"
ARG PYENV_ROOT="/opt/pyenv"
LABEL python_version=$PYTHON_VERSION

# Set environment variables.
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
#ENV LANG=POSIX
#ENV LANGUAGE=POSIX
#ENV LC_ALL=POSIX

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=C.UTF-8

ENV TZ=UTC

ENV HOME="/root"

## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://www.how2shout.com/linux/install-python-3-x-or-2-7-on-debian-11-bullseye-linux/
RUN apt-get update -y
#RUN apt-get install --no-install-recommends -y apt-utils sudo bash ca-certificates curl wget git tox
RUN apt-get install -y \
    apt-utils \
    build-essential \
    sudo \
    bash \
    ca-certificates \
    curl \
    wget \
    git

RUN apt-get install -y \
    python3 \
    python3-apt \
    python3-venv

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
#    && curl -fsSL -o openssl-1.1.1w.tar.gz https://www.openssl.org/source/openssl-1.1.1w.tar.gz \
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

WORKDIR /

COPY install-python-venv.sh .
RUN bash install-python-venv.sh ${PYTHON_VERSION} ${PYENV_ROOT}

## ref: https://www.baeldung.com/ops/dockerfile-path-environment-variable
#RUN echo "export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH" >> ~/.bashrc
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN echo "export PATH=$PATH" >> /etc/profile

RUN echo "alias ll='ls -Fla'" >> ~/.bashrc
RUN echo "alias la='ls -alrt'" >> ~/.bashrc

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]
#CMD ["/sbin/init", "--log-target=journal"]
##CMD ["/lib/systemd/systemd"]

COPY python-info.py .
RUN python3 python-info.py

COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
