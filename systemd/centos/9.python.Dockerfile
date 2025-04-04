## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos9-systemd:latest

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

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=C.UTF-8

ENV TZ=UTC

ENV HOME="/root"

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#COPY ./rpm-gpg-key-centos.txt /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
RUN curl -fsSL https://centos.org/keys/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

## ref: https://linuxconfig.org/redhat-8-epel-install-guide
## ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
## ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN yum-config-manager --enable epel

### ref: https://linuxconfig.org/redhat-8-epel-install-guide
### ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
### ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
#RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
##RUN yum-config-manager --enable epel

#RUN dnf upgrade -y
RUN dnf update -y

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
    python3-dnf \
    python3-pip \
    python3-libselinux

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

RUN echo "alias ll='ls -Fla'" >> ~/.bashrc
RUN echo "alias la='ls -alrt'" >> ~/.bashrc

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
RUN python3 python-info.py

COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
