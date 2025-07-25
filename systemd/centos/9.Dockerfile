## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
## https://pythonspeed.com/articles/multi-stage-docker-python/
## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1
ARG BASEOS_DIGEST
#FROM centos:9
#FROM quay.io/centos/centos:stream9
FROM quay.io/centos/centos:stream9${BASEOS_DIGEST:-}

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

ENV container=docker

RUN yum -y update \
    && yum -y install \
    epel-release \
    hostname \
    initscripts \
    iproute \
    openssl \
    sudo \
    which \
    jq \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && yum clean all

# selectively remove systemd targets -- See https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# hotfix for issue #49
RUN chmod 0400 /etc/shadow

## not necessary since /usr/local/bin is already in the PATH
#ENV PATH="${PIPX_BIN_DIR}:${PATH}"
RUN echo "PATH: ${PATH}"
RUN echo "export PATH=$PATH" >> /etc/profile
ENV PATH="/root/.local/bin:${PATH}"

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
