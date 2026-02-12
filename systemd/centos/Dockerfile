ARG VERSION=10
FROM quay.io/centos/centos:${VERSION}

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

ENV container=docker

# Path fix for CentOS 8-10: Use /usr/lib instead of /lib
# This cleans up systemd units to allow it to run properly in a container
# Step 8: Robust cleanup for systemd in container
RUN find /usr/lib/systemd/system/sysinit.target.wants/ -maxdepth 1 -type l -not -name 'systemd-tmpfiles-setup.service' -delete 2>/dev/null || true; \
    rm -f /usr/lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /usr/lib/systemd/system/local-fs.target.wants/* \
    /usr/lib/systemd/system/sockets.target.wants/*udev* \
    /usr/lib/systemd/system/sockets.target.wants/*initctl* \
    /usr/lib/systemd/system/basic.target.wants/* \
    /usr/lib/systemd/system/anaconda.target.wants/* || true

# FIX: Manually set the default target instead of using systemctl
#RUN systemctl set-default multi-user.target
RUN mkdir -p /etc/systemd/system/ && \
    ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# Remove machine-id to allow a fresh one to be generated at runtime
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id

RUN echo "alias ll='ls -Fla'" >> ~/.bashrc && \
    echo "alias la='ls -alrt'" >> ~/.bashrc

# Systemd requires cgroups to be mounted.
# In CentOS 9/10 (cgroup v2), the /sys/fs/cgroup volume is essential.
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

# Use the signal systemd expects for a clean shutdown
STOPSIGNAL SIGRTMIN+3

# Standard location for init in EL8/9/10
CMD ["/usr/sbin/init"]
