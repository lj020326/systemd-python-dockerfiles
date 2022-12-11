FROM lj020326/debian8-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## using approach used here:
## https://github.com/WyseNynja/dockerfile-debian/blob/jessie/Dockerfile
COPY ./docker-apt-install.sh /usr/local/sbin/docker-install

## Dependencies for Ansible
## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
RUN set -eux; \
    docker-install \
        dbus systemd systemd-cron rsyslog iproute2 \
        sudo bash ca-certificates \
        python python-apt python-pip \
        libldap2-dev libsasl2-dev slapd ldap-utils \
        build-essential python-dev

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
