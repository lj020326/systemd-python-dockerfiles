FROM lj020326/redhat7-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2022-07-06"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## disable subscription-manager
## ref: https://bugzilla.redhat.com/show_bug.cgi?id=1623262
#RUN subscription-manager config --rhsm.manage_repos=0
#RUN sed -i s/1/0/g /etc/yum/pluginconf.d/subscription-manager.conf

## enable EPEL
## ref: https://unix.stackexchange.com/questions/598028/how-to-install-epel-release-in-red-hat-linux-7-8
#RUN subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"  --enable "rhel-ha-for-rhel-*-server-rpms"

## this does not work for rhel7 container
#RUN yum -y install epel-release
#RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

## ref: https://webhostinggeeks.com/howto/epel-yum-repository-on-linux/
#RUN rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 &&\
#    rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm

## ref: https://access.redhat.com/discussions/3140721
RUN rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 &&\
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
#RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum install -y python sudo bash

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
