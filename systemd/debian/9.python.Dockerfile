ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/debian9-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023042601"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        sudo bash ca-certificates \
        && \
    apt-get clean && \
    rm -rf /usr/share/doc /usr/share/man /var/lib/apt/lists/* /tmp/* /var/tmp/*

## ref: https://stackoverflow.com/questions/75159821/installing-python-3-11-1-on-a-docker-container
RUN apt-get -y install build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        libbz2-dev \
        wget \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get purge -y imagemagick imagemagick-6-common

RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz \
    && tar -xzf Python-3.11.7.tgz \
    && cd Python-3.11.7 \
    && ./configure --enable-optimizations \
    && make altinstall

RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1

### ref: https://stackoverflow.com/questions/75159821/installing-python-3-11-1-on-a-docker-container
#RUN apt install software-properties-common -y
#RUN add-apt-repository "ppa:deadsnakes/ppa"
#RUN apt-get update -y
#RUN apt install python3.11 python3-pip -y

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
