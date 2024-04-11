ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos9-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023071001"

# Set environment variables.
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC

ENV HOME="/root"
ENV PYTHON_VERSION="3.11.7"

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#COPY ./rpm-gpg-key-centos.txt /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
RUN curl -fsSL https://centos.org/keys/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

## ref: https://linuxconfig.org/redhat-8-epel-install-guide
## ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
## ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN yum-config-manager --enable epel

RUN dnf upgrade -y

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
RUN dnf makecache \
    && dnf install --nodocs -y sudo bash git \
    && dnf install -y readline-devel bzip2-devel libffi-devel ncurses-devel sqlite-devel openssl-devel
    && dnf clean all

####################
## pyenv
WORKDIR $HOME
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

RUN pyenv install $PYTHON_VERSION
RUN env CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
    pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
RUN pyenv rehash

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
#CMD python info.py; /sbin/init
#CMD ["/bin/bash", "-c", "python info.py; /sbin/init"]

#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
COPY startup-sbin-init.sh .
CMD ["startup-sbin-init.sh"]

