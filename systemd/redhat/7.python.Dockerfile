ARG BUILD_ID=devel
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/redhat7-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build=$BUILD_ID

# Set environment variables.
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive
#ENV LANG=POSIX
#ENV LANGUAGE=POSIX
#ENV LC_ALL=POSIX

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
#ENV LANG=en_US.UTF-8
#ENV LANGUAGE=en_US.UTF-8
#ENV LC_CTYPE=en_US.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=C.UTF-8

ENV TZ=UTC

ENV HOME="/root"
ENV PYTHON_VERSION="3.11.7"

## ref: https://serverfault.com/questions/764900/how-to-remove-this-warning-this-system-is-not-registered-to-red-hat-subscriptio
## ref: https://stackoverflow.com/questions/11696113/yum-on-centos-stuck-at-loaded-plugins-fastestmirror
## ref: https://github.com/RHsyseng/container-rhel-examples/blob/master/starter/Dockerfile
## ref: https://pnyiu.github.io/2017/11/17/Docker-on-RHEL-7-4-Apache-HTTPD-and-Tomcat/
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

#RUN yum repolist --disablerepo=* && \
#    yum-config-manager --disable \* > /dev/null

#COPY ./repos/centos7-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./repos/centos7-extras.repo.ini /etc/yum.repos.d/centos-extras.repo
RUN yum update -y

## yum repolist all
##RUN yum-config-manager --enable ubi-7
#RUN yum-config-manager --enable ubi-7 ubi-7-server-devtools-rpms*
#RUN yum-config-manager --enable ubi-7 ubi-7-server-extras-rpms
RUN yum-config-manager --enable ubi-7  \
    ubi-7-rhah \
    ubi-7-server-devtools-rpms  \
    ubi-7-server-optional-rpms \
    ubi-server-rhscl-7-rpms
##RUN yum-config-manager --disable ubi-7-server-extras-rpms*
RUN yum update -y

## ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
## ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
RUN yum update -y

### MUST install devel libs for python-ldap to work
### ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
### MUST install devel libs for python-ldap to work
##RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum makecache \
    && yum install -y gcc make sudo bash which git

RUN yum install -y readline-devel bzip2 bzip2-devel \
        zlib-devel krb5-devel libffi-devel ncurses-devel sqlite-devel xz-devel

#RUN yum install -y openssl11 openssl-devel openssl11-devel openssl11-lib
RUN yum install -y openssl11 openssl-devel openssl11-devel

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
RUN CPPFLAGS=$(pkg-config --cflags openssl11) LDFLAGS=$(pkg-config --libs openssl11) \
    pyenv install $PYTHON_VERSION
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
