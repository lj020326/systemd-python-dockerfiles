FROM jrei/systemd-centos:8
#FROM media.johnson.int/systemd-centos-8:latest
LABEL maintainer="Lee Johnson <ljohnson@dettonville.org>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8

# Dependencies for Ansible
RUN dnf makecache && dnf install --nodocs -y bash python3 sudo && dnf clean all

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
