## ref: https://stackoverflow.com/questions/74531081/debian-8-jessie-archive-debian-org-gpg-error-keyexpired-since-2022-11-19-what-n
#FROM debian:jessie
FROM debian/eol:jessie
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023042601"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## ref: https://stackoverflow.com/questions/52939411/build-error-failed-to-fetch-http-deb-debian-org-debian-dists-jessie-updates-m
#RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list
#RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list

## ref: https://stackoverflow.com/questions/52939411/build-error-failed-to-fetch-http-deb-debian-org-debian-dists-jessie-updates-m
#RUN sed -i '/jessie-updates/d' /etc/apt/sources.list \
#    && sed -i '/jessie\/updates/d' /etc/apt/sources.list
#
#RUN apt-get update \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################################
##
## Currently (4/27/2023) getting the following error when using debian:jessie
##
## The following packages have unmet dependencies:
##  systemd : Depends: libapparmor1 (>= 2.9.0-3+exp2) but 2.9.0-3 is to be installed
##            Recommends: libpam-systemd but it is not going to be installed
##            Recommends: dbus but it is not going to be installed
##            Breaks: udev (< 228-5) but 215-17+deb8u13 is to be installed
##
##  systemd : Depends: libsystemd0 (= 232-25+deb9u12) but 232-25+deb9u13 is to be installed
##            Recommends: libpam-systemd but it is not going to be installed
## E: Unable to correct problems, you have held broken packages.
##
## As a workaround to mixed versions causing this, we downgrade libsystemd packages to 232-25+deb9u12
## and mark the systemd package to hold current version to prevent issue upon next `apt update`
##
RUN apt-get update \
    && apt-get install --allow-downgrades -y dbus \
            libapparmor1=2.9.0-3+exp2 \
            systemd \
            udev=228-5 \
    && apt-mark hold libapparmor1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN apt-get update \
#    && apt-get install -y systemd \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

### using approach used here:
### https://github.com/WyseNynja/dockerfile-debian/blob/jessie/Dockerfile
#COPY ./docker-apt-install.sh /usr/local/sbin/docker-install
#
### ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
### deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main
#RUN set -eux; \
#    docker-install systemd systemd-sysv

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
