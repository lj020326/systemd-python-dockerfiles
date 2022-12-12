FROM lj020326/redhat7-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

#COPY ./centos-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./centos-extras.repo.ini /etc/yum.repos.d/centos-extras.repo
#COPY ./redhat-epel.repo.ini /etc/yum.repos.d/epel.repo

## ref: https://serverfault.com/questions/764900/how-to-remove-this-warning-this-system-is-not-registered-to-red-hat-subscriptio
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf \
    && sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf \
    && sed -i 's/enabled=1/enabled=0/g' /etc/yum.conf

RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
#RUN yum-config-manager --enable epel

RUN yum update -y

## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
RUN yum -y install \
    sudo bash \
    openldap-devel \
    python python-devel

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
