ARG IMAGE_REGISTRY=registry.johnson.int:5000
FROM $IMAGE_REGISTRY/debian11-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2022121501"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://www.how2shout.com/linux/install-python-3-x-or-2-7-on-debian-11-bullseye-linux/
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      dbus systemd systemd-cron rsyslog iproute2 \
      sudo bash ca-certificates \
      python3 python3-apt python3-pip \
      build-essential python3-dev python2.7-dev \
      libldap2-dev libsasl2-dev slapd ldap-utils tox \
      && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

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
VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

# A different stop signal is required, so systemd will initiate a shutdown when
# running 'docker stop <container>'.
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init", "--log-target=journal"]
#CMD ["/lib/systemd/systemd"]
