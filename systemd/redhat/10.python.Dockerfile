## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
## ref: https://github.com/devfile/developer-images/blob/main/base/ubi9/Dockerfile
## ref: https://access.redhat.com/articles/4238681
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/redhat10-systemd:latest

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

RUN dnf --disableplugin subscription-manager update -y
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

#COPY ./repos/redhat-ubi.repo.ini /etc/yum.repos.d/ubi.repo
#COPY ./repos/redhat-epel.repo.ini /etc/yum.repos.d/epel.repo

RUN curl https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}')

##COPY ./rpm-gpg-key-centos.txt /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
RUN curl https://centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

#RUN dnf install -y yum-utils

RUN dnf update -y

### ref: https://linuxconfig.org/redhat-8-epel-install-guide
### ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
### ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
##RUN yum-config-manager --enable epel

## rpm build/installs require "source" repo enabled
#RUN yum-config-manager --enable ubi-9-baseos-source ubi-9-appstream-source
#RUN yum-config-manager --enable ubi-9-baseos-source-rpms ubi-9-appstream-source-rpms
RUN dnf install -y \
    --enablerepo ubi-$(rpm -E '%{rhel}')-baseos-rpms \
    --enablerepo ubi-$(rpm -E '%{rhel}')-baseos-source-rpms \
    --enablerepo ubi-$(rpm -E '%{rhel}')-appstream-rpms \
    --enablerepo ubi-$(rpm -E '%{rhel}')-appstream-source-rpms \
    bash \
    which

#RUN dnf upgrade -y
RUN dnf update -y

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
#RUN dnf makecache \
#    && dnf groupinstall -y "Development Tools" \
RUN dnf makecache \
    && dnf install -y python3 python3-dnf

RUN dnf clean all

### ref: https://github.com/devfile/developer-images/blob/main/base/ubi9/Dockerfile
## Removed because of vulnerabilities: git-lfs
#RUN dnf install -y diffutils git iproute jq less lsof man nano procps \
#    perl-Digest-SHA net-tools openssh-clients rsync socat sudo time vim wget zip

WORKDIR /

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

COPY python-info.py .
RUN python3 python-info.py

COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
