## ref: https://schneide.blog/2019/10/21/using-parameterized-docker-builds/
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos7-systemd:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ARG BUILD_DATE
ARG BUILD_ID=devel
LABEL build=$BUILD_ID

## versions at https://www.python.org/ftp/python/
#ARG PYTHON_VERSION="3.11.9"
ARG PYTHON_VERSION="3.12.9"
#ARG PYENV_ROOT="/pyenv"
ARG PYENV_ROOT="/opt/pyenv"
LABEL python_version=$PYTHON_VERSION

# Set environment variables.
ENV container=docker

## ref: https://www.cyberciti.biz/faq/failed-to-set-locale-defaulting-to-c-warning-message-on-centoslinux/
#ENV LANG=C.UTF-8
#ENV LANGUAGE=C.UTF-8
#ENV LC_COLLATE=C
#ENV LC_CTYPE=C.UTF-8

# ref: http://superuser.com/questions/331242/ddg#721223
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=en_US.UTF-8

ENV TZ=UTC

ENV HOME="/root"

COPY ./repos/centos7.yum.conf /etc/yum.conf
COPY ./repos/centos7-linux-base.repo.ini /etc/yum.repos.d/CentOS-Base.repo
#COPY ./repos/centos-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./repos/centos-extras.repo.ini /etc/yum.repos.d/centos-extras.repo

COPY ./repos/epel7.repo.ini /etc/yum.repos.d/epel.repo

RUN curl https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$(rpm -E '%{rhel}')

#RUN curl https://vault.centos.org/RPM-GPG-KEY-CentOS-$(rpm -E '%{rhel}') \
#    -o /etc/pki/rpm-gpg/RPM-GPG-CentOS-$(rpm -E '%{rhel}')

RUN curl https://vault.centos.org/RPM-GPG-KEY-CentOS-$(rpm -E '%{rhel}') \
    -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## MUST install devel libs for python-ldap to work
RUN yum update -y

## yum repolist all

RUN yum install -y epel-release

RUN yum makecache \
    && yum groupinstall -y "Development tools" \
    && yum install -y \
        sudo \
        bash \
        which \
        git \
        wget

RUN yum install -y \
    python3 \
    python3-pip \
    python3-libselinux \
    python3-virtualenv

## yum list [reponame]
RUN yum install -y \
    bzip2-devel \
    krb5-devel \
    libffi-devel \
    ncurses-devel \
    openssl-devel \
    readline-devel \
    sqlite-devel \
    xz-devel \
    zlib-devel

#RUN yum install -y openssl11 openssl11-devel openssl11-libs
RUN yum install -y openssl11 openssl11-devel

####################
## pyenv
#WORKDIR $HOME
#RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv
#ENV PYENV_ROOT="$HOME/.pyenv"

WORKDIR /

## ref: https://github.com/pyenv/pyenv/issues/281
## ref: https://discuss.python.org/t/build-python3-11-5-with-static-openssl-and-libffi-on-centos7/37485/5
## ref: https://serverfault.com/questions/973470/in-centos-what-does-the-line-ld-library-path-usr-local-lib-usr-local-lib64-do
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64
ENV PKG_CONFIG_PATH=/usr/lib64/pkgconfig

COPY install-python-venv.sh .

RUN CPPFLAGS=$(pkg-config --cflags openssl11) \
    LDFLAGS=$(pkg-config --libs openssl11) \
    bash install-python-venv.sh ${PYTHON_VERSION} ${PYENV_ROOT}

## ref: https://www.baeldung.com/ops/dockerfile-path-environment-variable
#RUN echo "export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH" >> ~/.bashrc
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN echo "export PATH=$PATH" >> /etc/profile

RUN echo "alias ll='ls -Fla'" >> ~/.bashrc
RUN echo "alias la='ls -alrt'" >> ~/.bashrc

## ref: https://www.baeldung.com/linux/docker-cmd-multiple-commands
## ref: https://taiwodevlab.hashnode.dev/running-multiple-commands-on-docker-container-start-cl3gc8etn04k4mynvg4ub3wss
#CMD ["/sbin/init"]
##CMD ["/usr/sbin/init"]
##CMD ["/usr/lib/systemd/systemd"]

COPY python-info.py .
RUN python3 python-info.py

COPY start-sbin-init.sh .
CMD ["startup-sbin-init.sh"]
