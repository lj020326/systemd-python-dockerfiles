FROM jrei/systemd-centos:7
#FROM media.johnson.int/systemd-centos-7:latest
LABEL maintainer="Lee Johnson <ljohnson@dettonville.org>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
#RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum install -y python sudo bash
RUN yum clean all

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
