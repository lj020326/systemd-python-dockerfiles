ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/redhat7-systemd:latest
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

## ref: https://serverfault.com/questions/764900/how-to-remove-this-warning-this-system-is-not-registered-to-red-hat-subscriptio
## ref: https://stackoverflow.com/questions/11696113/yum-on-centos-stuck-at-loaded-plugins-fastestmirror
## ref: https://github.com/RHsyseng/container-rhel-examples/blob/master/starter/Dockerfile
## ref: https://pnyiu.github.io/2017/11/17/Docker-on-RHEL-7-4-Apache-HTTPD-and-Tomcat/
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null

#COPY ./repos/centos7-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./repos/centos7-extras.repo.ini /etc/yum.repos.d/centos-extras.repo

## yum repolist all
RUN yum-config-manager --enable ubi-7
#RUN yum-config-manager --enable ubi-7 ubi-7-server-extras-rpms ubi-7-server-devtools-rpms
#RUN yum-config-manager --disable ubi-7-server-extras-rpms*
RUN yum update -y

## ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
## ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
RUN yum update -y

### ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
#RUN yum -y install bash python

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## MUST install devel libs for python-ldap to work
#RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum makecache \
    && yum install -y gcc make sudo bash which git

RUN yum install -y \
    python \
    python-pip \
    python-jinja2 \
    libselinux-python \
    python-netaddr \
    python3 \
    python3-pip \
    python3-libselinux \
    python3-devel

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
