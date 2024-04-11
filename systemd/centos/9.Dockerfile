#########
## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1
#FROM centos:9
FROM quay.io/centos/centos:stream9
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2024-04-10"

ENV container docker

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
RUN yum groupinstall -y "Development Tools" && \
  yum install -y libcap-devel gperf glib2-devel python3-pip jq

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
## ref: https://stackoverflow.com/questions/48098671/build-with-docker-and-privileged#57077772
COPY ./install-systemd.sh /var/tmp/
RUN bash -x /var/tmp/install-systemd.sh

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
