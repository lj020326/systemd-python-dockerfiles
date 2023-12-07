#########
## https://pythonspeed.com/articles/multi-stage-docker-python/

## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1
#FROM centos:9
FROM quay.io/centos/centos:stream9 AS compile-venv-image
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2023-07-10"

ENV container docker
ENV PIP_ROOT_USER_ACTION ignore

## ref: https://pythonspeed.com/articles/multi-stage-docker-python/
RUN python3 -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

## meson is required for subsequent systemd install by install-systemd.sh appearing later in this docker build
RUN pip3 install meson ninja jinja2

FROM quay.io/centos/centos:stream9 AS build-image
COPY --from=compile-venv-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
RUN yum groupinstall -y "Development Tools" && \
  yum install -y libcap-devel gperf glib2-devel python3-pip jq

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
## ref: https://stackoverflow.com/questions/48098671/build-with-docker-and-privileged#57077772
COPY ./install-systemd.sh /var/tmp/
RUN bash -x /var/tmp/install-systemd.sh

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

#VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

## ref: https://unix.stackexchange.com/questions/276340/linux-command-systemctl-status-is-not-working-inside-a-docker-container
CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]
