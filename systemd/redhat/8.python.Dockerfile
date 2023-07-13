ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/redhat8-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023071001"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN dnf --disableplugin subscription-manager update -y
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

COPY ./repos/redhat-ubi.repo.ini /etc/yum.repos.d/ubi.repo
COPY ./repos/redhat-epel.repo.ini /etc/yum.repos.d/epel.repo

COPY ./repos/centos8-linux-baseOS.repo.ini /etc/yum.repos.d/CentOS-Linux-BaseOS.repo
#COPY ./repos/centos8-linux-extras.repo.ini /etc/yum.repos.d/CentOS-Linux-Extras.repo
COPY ./repos/centos8-linux-appstream.repo.ini /etc/yum.repos.d/CentOS-Linux-AppStream.repo

#RUN curl https://centos.org/keys/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
#
### ref: https://linuxconfig.org/redhat-8-epel-install-guide
### ref: https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it
### ref: https://docs.rackspace.com/support/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat
#RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
##RUN yum-config-manager --enable epel

RUN dnf upgrade -y

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
RUN dnf makecache && \
    dnf install --nodocs -y \
        sudo \
        bash \
        python3 && \
    dnf clean all

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

CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]
