ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/fedora35-systemd:latest
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

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### ref: https://stackoverflow.com/questions/56908604/trying-to-install-epel-release-on-fedora-30-no-match-for-argument-epel-relea
#RUN dnf -y install passenger

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
RUN dnf makecache \
    && dnf groupinstall --nobest -y "Development Tools" \
    && dnf install --nodocs -y sudo bash which git \
    && dnf install --nodocs -y readline-devel bzip2-devel libffi-devel ncurses-devel sqlite-devel openssl-devel xz-devel \
    && dnf clean all

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

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
