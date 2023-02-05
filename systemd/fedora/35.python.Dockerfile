ARG IMAGE_REGISTRY=media.johnson.int:5000
FROM $IMAGE_REGISTRY/fedora35-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023010401"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# ref: https://namespaceit.com/blog/failed-to-download-metadata-for-repo-appstream-cannot-prepare-internal-mirrorlist-no-urls-in-mirrorlist
#RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* &&\
#    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
#
#RUN dnf upgrade -y

# Dependencies for Ansible
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
RUN dnf makecache && dnf install --nodocs -y bash python3 sudo && dnf clean all

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
