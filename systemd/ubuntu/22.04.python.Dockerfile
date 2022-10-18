FROM lj020326/ubuntu2204-systemd:latest
#FROM registry.johnson.int/systemd-ubuntu2204:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2022-07-06"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-ubuntu-systemd/blob/master/Dockerfile
## ref: https://stackoverflow.com/questions/4768446/i-cant-install-python-ldap
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        dbus systemd systemd-cron rsyslog iproute2 \
        sudo bash ca-certificates \
        python3 python3-apt python3-pip \
        build-essential python3-dev \
        libldap2-dev libsasl2-dev libssl-dev slapd ldap-utils tox \
        && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init", "--log-target=journal"]
#CMD ["/lib/systemd/systemd"]
