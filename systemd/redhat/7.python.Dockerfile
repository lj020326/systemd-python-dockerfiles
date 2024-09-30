## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/redhat7-systemd:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

#ARG PYTHON_VERSION="3.11.9"
ARG PYTHON_VERSION="3.12.3"

ARG BUILD_ID=devel
LABEL build=$BUILD_ID

# Set environment variables.
ENV container=docker

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
#ENV LANG=C.UTF-8
#ENV LANGUAGE=C.UTF-8
#ENV LC_COLLATE=C
#ENV LC_CTYPE=C.UTF-8

# ref: http://superuser.com/questions/331242/ddg#721223
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=en_US.UTF-8

ENV TZ=UTC

ENV HOME="/root"

## ref: https://serverfault.com/questions/764900/how-to-remove-this-warning-this-system-is-not-registered-to-red-hat-subscriptio
## ref: https://stackoverflow.com/questions/11696113/yum-on-centos-stuck-at-loaded-plugins-fastestmirror
## ref: https://github.com/RHsyseng/container-rhel-examples/blob/master/starter/Dockerfile
## ref: https://pnyiu.github.io/2017/11/17/Docker-on-RHEL-7-4-Apache-HTTPD-and-Tomcat/
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

#RUN yum repolist --disablerepo=* && \
#    yum-config-manager --disable \* > /dev/null

## ref: https://stackoverflow.com/questions/65878769/cannot-install-docker-in-a-rhel-server
COPY ./repos/centos7-os.repo.ini /etc/yum.repos.d/centos-os.repo
COPY ./repos/centos7-extras.repo.ini /etc/yum.repos.d/centos-extras.repo
COPY ./repos/centos7-updates.repo.ini /etc/yum.repos.d/centos-updates.repo

##COPY ./repos/redhat-epel.repo.ini /etc/yum.repos.d/epel.repo
#COPY ./repos/epel7.repo.ini /etc/yum.repos.d/epel.repo

RUN curl https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}')

#RUN curl https://vault.centos.org/RPM-GPG-KEY-CentOS-$(rpm -E '%{rhel}') \
#    -o /etc/pki/rpm-gpg/RPM-GPG-CentOS-$(rpm -E '%{rhel}')

RUN curl https://vault.centos.org/RPM-GPG-KEY-CentOS-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

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

### ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
### ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
#RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN yum update -y
RUN yum install -y epel-release

### MUST install devel libs for python-ldap to work
### ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
##RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum makecache \
    && yum install -y \
      gcc \
      make \
      sudo \
      bash \
      which \
      git \
      wget

RUN yum install -y \
    python3 \
    python3-pip \
    python3-libselinux \
    python3-virtualenv \
    python3-devel

## yum list [reponame]
RUN yum install -y \
    bzip2-devel \
    krb5-devel \
    libffi-devel \
    ncurses-devel \
    openssl-devel \
    readline-devel \
    sqlite-devel \
    xz-devel \
    zlib-devel

## install readline-devel from source
## ref: https://www.thegeekstuff.com/2015/02/rpm-build-package-example/
## ref: https://blog.packagecloud.io/working-with-source-rpms/
#RUN wget http://vault.centos.org/7.9.2009/os/Source/SPackages/readline-6.2-11.el7.src.rpm

## rpm build/installs require "source" repo enabled
RUN yum-config-manager --enable ubi-7-server-source-rpms
RUN yum install -y rpm-build

### download readline bzip2 source rpms to install *-devel.rpm packages required for python build
#COPY build-rpm-source.sh .
#RUN bash build-rpm-source.sh readline bzip2

#RUN yum install -y openssl11 openssl11-devel openssl11-libs
RUN yum install -y openssl11 openssl11-devel

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
