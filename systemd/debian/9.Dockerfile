FROM debian:stretch
#FROM debian:stretch-20220622
#FROM debian:stretch-20220125
#FROM debian:stretch-20210721
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023042601"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://unix.stackexchange.com/questions/371890/debian-the-repository-does-not-have-a-release-file
##RUN echo "deb http://archive.debian.org/debian stretch main contrib" > /etc/apt/sources.list
#RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list
#RUN echo "deb http://archive.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list

COPY ./repos/debian9.repo.ini /etc/apt/sources.list

## ref: https://stackoverflow.com/questions/52939411/build-error-failed-to-fetch-http-deb-debian-org-debian-dists-jessie-updates-m
#RUN sed -i '/stretch-updates/d' /etc/apt/sources.list \
#    && sed -i '/stretch\/updates/d' /etc/apt/sources.list

################################
##
## Currently (4/27/2023) getting the following error when using debian:stretch
##
## The following packages have unmet dependencies:
##  systemd : Depends: libsystemd0 (= 232-25+deb9u12) but 232-25+deb9u13 is to be installed
##            Recommends: libpam-systemd but it is not going to be installed
## E: Unable to correct problems, you have held broken packages.
##
## As a workaround to mixed versions causing this, we downgrade libsystemd packages to 232-25+deb9u12
## and mark the systemd package to hold current version to prevent issue upon next `apt update`
##
#RUN apt-get update \
#    && apt-get install --allow-downgrades -y dbus \
#            libsystemd0=232-25+deb9u12 \
#            systemd=232-25+deb9u12 \
#    && apt-get install --allow-downgrades -y \
#            iptables=1.6.0+snapshot20161117-6 \
#            libip4tc0=1.6.0+snapshot20161117-6 \
#    && apt-get install --allow-downgrades -y curl \
#            libcurl3 libgnutls30 libhogweed4 libnettle6=3.3-1+b2 \
#    && apt-get install --allow-downgrades -y \
#            zlib1g-dev=1:1.2.8.dfsg-5 zlib1g=1:1.2.8.dfsg-5 \
#    && apt-mark hold systemd iptables curl zlib1g-dev \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update \
    && apt-get install -y dbus systemd \
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
