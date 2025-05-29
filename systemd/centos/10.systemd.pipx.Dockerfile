## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1

#FROM centos:10
FROM quay.io/centos/centos:stream10

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

ENV container=docker

## Install systemd
## ref: https://linuxopsys.com/topics/install-systemd
RUN yum groupinstall -y "Development Tools" && \
  dnf install -y \
    libcap-devel \
    gperf \
    glib2-devel \
    jq \
    which \
    python3-pip

## use --global option instead
#ENV PIPX_HOME="/opt/pipx"
#ENV PIPX_BIN_DIR="/usr/local/bin"

## not necessary since /usr/local/bin is already in the PATH
#ENV PATH="${PIPX_BIN_DIR}:${PATH}"
RUN echo "PATH: ${PATH}"
RUN echo "export PATH=$PATH" >> /etc/profile
ENV PATH="/root/.local/bin:${PATH}"

## ref: https://pipx.pypa.io/stable/installation/
RUN python3 -m pip install --user pipx jinja2

## not necessary since /usr/local/bin is already in PATH
#RUN pipx ensurepath --global
#RUN python3 -m pipx ensurepath

#RUN pip install meson ninja jinja2
## ref: https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3
## ref: https://github.com/pypa/pipx/issues/754#issuecomment-951162846
RUN pipx install --global meson ninja
#RUN python3 -m pipx install --global meson ninja

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
