FROM alpine:edge

RUN apk add --update --upgrade --no-cache --force-overwrite alpine-sdk
#RUN echo 'dev    ALL=(ALL) ALL' >> /etc/sudoers
#RUN adduser dev -u 1000 -DG abuild
#RUN su dev -c 'abuild-keygen -an'
#RUN cat /home/dev/.abuild/abuild.conf > /etc/abuild.conf

RUN rm -rf "/tmp/"* \
    && echo 'rc_provide="loopback net"' >> /etc/rc.conf \
    && sed -i -e 's/#rc_sys=""/rc_sys="lxc"/g' -e 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
    && sed -i '/tty/d' /etc/inittab \
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh

ENTRYPOINT ["/sbin/init"]
