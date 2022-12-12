FROM registry.access.redhat.com/rhel7:latest
#FROM richxsl/rhel7
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ENV container docker

#COPY ./centos-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./centos-extras.repo.ini /etc/yum.repos.d/centos-extras.repo
#COPY ./redhat-epel.repo.ini /etc/yum.repos.d/epel.repo

## ref: https://serverfault.com/questions/764900/how-to-remove-this-warning-this-system-is-not-registered-to-red-hat-subscriptio
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf \
    && sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf \
    && sed -i 's/enabled=1/enabled=0/g' /etc/yum.conf

## Update image
#RUN yum repolist --disablerepo=* && \
#    yum-config-manager --disable \* > /dev/null && \
#    yum-config-manager --enable rhel-7-server-rpms > /dev/null
#RUN yum update -y

### Add necessary Red Hat repos here
#RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms && \
#    yum -y update-minimal --disablerepo "*" --enablerepo rhel-7-server-rpms --setopt=tsflags=nodocs \
#      --security --sec-severity=Important --sec-severity=Critical && \
#    yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs \

RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN yum-config-manager --enable epel

RUN yum update -y

RUN cd /lib/systemd/system/sysinit.target.wants/; \
    for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i; done

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]
