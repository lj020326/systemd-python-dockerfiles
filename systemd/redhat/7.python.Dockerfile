FROM lj020326/redhat7-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2022-07-06"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN echo "[centos-os]\n\
name=Centos os - $basearch\n\
baseurl=http://mirror.centos.org/centos/7/os/x86_64/\n\
enabled=1\n\
gpgcheck=0\n\
" > /etc/yum.repos.d/centos-os.repo

RUN echo "[centos-extras]\n\
name=Centos extras - $basearch\n\
baseurl=http://mirror.centos.org/centos/7/extras/x86_64\n\
enabled=1\n\
gpgcheck=0\n\
" > /etc/yum.repos.d/centos-extras.repo

## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
