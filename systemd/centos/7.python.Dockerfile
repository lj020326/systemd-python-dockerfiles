ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos7-systemd:latest
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

#COPY ./repos/centos-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./repos/centos-extras.repo.ini /etc/yum.repos.d/centos-extras.repo

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## MUST install devel libs for python-ldap to work
RUN yum install -y epel-release
RUN yum update -y

RUN yum makecache \
    && yum install -y sudo bash which git \
    && yum install -y readline-devel bzip2-devel libffi-devel ncurses-devel sqlite-devel openssl-devel \
    && yum clean all

####################
## pyenv
WORKDIR $HOME
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

## ref: https://github.com/pyenv/pyenv/issues/2760#issuecomment-1868608898
## ref: https://github.com/pyenv/pyenv/issues/2416
RUN env CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib64/openssl -lssl -lcrypto" CFLAGS=-fPIC \
    pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
RUN pyenv rehash

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
