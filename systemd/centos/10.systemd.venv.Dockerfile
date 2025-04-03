## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
## https://pythonspeed.com/articles/multi-stage-docker-python/
## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1

#FROM centos:10
FROM quay.io/centos/centos:stream10 AS compile-venv-image
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ARG BUILD_ID=devel
LABEL build=$BUILD_ID

ENV container=docker
ENV PIP_ROOT_USER_ACTION=ignore

## ref: https://pythonspeed.com/articles/multi-stage-docker-python/
RUN python3 -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

## meson is required for subsequent systemd install by install-systemd.sh appearing later in this docker build
RUN pip3 install meson ninja jinja2

FROM quay.io/centos/centos:stream10 AS build-image
COPY --from=compile-venv-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
RUN yum groupinstall -y "Development Tools" && \
  yum install -y libcap-devel gperf glib2-devel jq
#  yum install -y libcap-devel gperf glib2-devel python3-pip jq

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

RUN echo "alias ll='ls -Fla'" >> ~/.bashrc
RUN echo "alias la='ls -alrt'" >> ~/.bashrc

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
