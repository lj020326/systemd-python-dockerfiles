## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
FROM centos:7
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ARG BUILD_ID=devel
LABEL build=$BUILD_ID

ENV container=docker

COPY ./repos/centos7.yum.conf /etc/yum.conf
COPY ./repos/centos7-linux-base.repo.ini /etc/yum.repos.d/CentOS-Base.repo

RUN curl https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}')

RUN yum -y update
RUN yum -y install systemd
#RUN yum clean all

## ref: https://github.com/geerlingguy/docker-centos8-ansible/blob/master/Dockerfile
RUN cd /lib/systemd/system/sysinit.target.wants/; \
    for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i; done

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

RUN systemctl set-default multi-user.target

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

# The host's cgroup filesystem need's to be mounted (read-only) in the
# container. '/run', '/run/lock' and '/tmp' need to be tmpfs filesystems when
# running the container without 'CAP_SYS_ADMIN'.
#
# NOTE: For running Debian stretch, 'CAP_SYS_ADMIN' still needs to be added, as
#       stretch's version of systemd is not recent enough. Buster will run just
#       fine without 'CAP_SYS_ADMIN'.
#VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

# A different stop signal is required, so systemd will initiate a shutdown when
# running 'docker stop <container>'.
STOPSIGNAL SIGRTMIN+3

## ref: https://unix.stackexchange.com/questions/276340/linux-command-systemctl-status-is-not-working-inside-a-docker-container
CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]
