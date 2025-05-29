## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/debian12-systemd:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

#ARG PYTHON_VERSION="3.11.9"
ARG PYTHON_VERSION="3.12.3"

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

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
RUN apt-get install -y apt-utils \
    build-essential \
    sudo bash ca-certificates \
    curl wget git

RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-apt \
    python3-dev \
    python3-virtualenv \
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

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
