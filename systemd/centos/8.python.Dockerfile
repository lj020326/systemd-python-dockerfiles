## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos8-systemd:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

#ARG PYTHON_VERSION="3.11.9"
ARG PYTHON_VERSION="3.12.3"

ARG BUILD_ID=devel
LABEL build=$BUILD_ID

# Set environment variables.
ENV container=docker

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=C.UTF-8

ENV TZ=UTC

ENV HOME="/root"

RUN dnf upgrade -y

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
#RUN dnf makecache \
#    && dnf groupinstall --nobest -y "Development Tools" \
RUN dnf makecache \
    && dnf install -y yum-utils \
    && dnf install -y gcc make \
    && dnf install --nodocs -y \
      sudo \
      bash \
      which \
      git \
      wget

RUN dnf install -y \
    python3 \
    python3-pip \
    python3-libselinux \
    python3-virtualenv

RUN dnf install --nodocs -y \
    bzip2-devel \
    libffi-devel \
    ncurses-devel \
    openssl-devel \
    readline-devel \
    sqlite-devel \
    xz-devel \
    zlib-devel

RUN dnf clean all

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
