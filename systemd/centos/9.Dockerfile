#FROM centos:9

## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1
FROM quay.io/centos/centos:stream9
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2023-07-10"

ENV container docker

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

#VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

## ref: https://unix.stackexchange.com/questions/276340/linux-command-systemctl-status-is-not-working-inside-a-docker-container
#CMD ["/sbin/init"]
CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]
