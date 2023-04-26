FROM debian:stretch
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023042601"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://unix.stackexchange.com/questions/371890/debian-the-repository-does-not-have-a-release-file
#RUN echo "deb http://archive.debian.org/debian stretch main contrib" > /etc/apt/sources.list

## ref: https://stackoverflow.com/questions/52939411/build-error-failed-to-fetch-http-deb-debian-org-debian-dists-jessie-updates-m
#RUN sed -i '/stretch-updates/d' /etc/apt/sources.list  # Now archived

#RUN apt-get update \
RUN apt-get --allow-releaseinfo-change update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && rm $(ls | grep -v systemd-tmpfiles-setup)

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/sbin/init"]
#CMD ["/lib/systemd/systemd"]
