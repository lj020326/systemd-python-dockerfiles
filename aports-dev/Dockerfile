ARG VERSION="edge"

# Use the Docker Hub Mirror (often cached on GHA runners)
#FROM alpine:edge
FROM public.ecr.aws/docker/library/alpine:${VERSION}

RUN apk add --update --upgrade --no-cache --force-overwrite alpine-sdk openrc

RUN rm -rf "/tmp/"* \
    && echo 'rc_provide="loopback net"' >> /etc/rc.conf \
    && sed -i -e 's/#rc_sys=""/rc_sys="lxc"/g' -e 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
    && sed -i '/tty/d' /etc/inittab \
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /usr/libexec/rc/sh/init.sh

ENTRYPOINT ["/sbin/init"]
