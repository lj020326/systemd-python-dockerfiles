[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml)
[![License](https://img.shields.io/badge/license-GPLv3-brightgreen.svg?style=flat)](LICENSE)

# systemd-python docker images

The systemd-python enabled docker images defined here can be found on [dockerhub](https://hub.docker.com/repositories/lj020326?search=systemd).  

## Status

[![GitHub issues](https://img.shields.io/github/issues/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/issues)
[![GitHub stars](https://img.shields.io/github/stars/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/stargazers)
[![Docker Pulls - centos7-systemd-python](https://img.shields.io/docker/pulls/lj020326/centos7-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/centos7-systemd-python/)
[![Docker Pulls - centos8-systemd-python](https://img.shields.io/docker/pulls/lj020326/centos8-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/centos8-systemd-python/)
[![Docker Pulls - redhat8-systemd-python](https://img.shields.io/docker/pulls/lj020326/redhat8-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/redhat8-systemd-python/)
[![Docker Pulls - ubuntu2204-systemd-python](https://img.shields.io/docker/pulls/lj020326/ubuntu2204-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/ubuntu2204-systemd-python/)
[![Docker Pulls - debian12-systemd-python](https://img.shields.io/docker/pulls/lj020326/debian12-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/debian12-systemd-python/)

## Directory structure

- [aports-dev](./aports-dev) contains an image for Alpine Linux aports development.
- [openrc](./openrc) and [systemd](./systemd) contain init-enabled docker images in which services are able to run.

## Run molecule tests

The example below uses [ansible-datacenter molecule tests](https://github.com/lj020326/ansible-datacenter/tree/main/molecule)

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ export MOLECULE_DISTRO=redhat7-systemd-python
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package
$ MOLECULE_DISTRO=redhat8-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule converge
$ molecule destroy
$ MOLECULE_DISTRO=centos8-systemd-python molecule --debug converge
$ molecule destroy
$ MOLECULE_DISTRO=ubuntu2204-systemd-python molecule --debug converge

```

To log into container

```shell
$ MOLECULE_DISTRO=redhat8-systemd-python molecule create
$ MOLECULE_DISTRO=redhat8-systemd-python molecule login
$ molecule destroy
```

To log into pure public docker images:
```shell
docker exec -it lj020326/centos9-systemd:latest bash
docker exec -it lj020326/centos9-systemd-python:latest bash
```

To log into pure private docker image:
```shell
$ importsslcert media.johnson.int:5000
$ docker login media.johnson.int:5000
$ docker pull media.johnson.int:5000/centos9-systemd:latest
## Run the systemd container as a daemon
$ docker run -d --name centos9-systemd --privileged --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro media.johnson.int:5000/centos9-systemd
$ docker exec -it centos9-systemd bash
## run the python enabled systemd container image
$ docker run -d --name centos9-systemd-python --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro media.johnson.int:5000/centos9-systemd-python
$ docker exec -it centos9-systemd-python bash
```

To override entrypoint and run bash instead:
```shell
$ docker run -it --name centos9-systemd --entrypoint /bin/bash --privileged --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro media.johnson.int:5000/centos9-systemd
```

## Building images

To build an image using centos9-systemd as an example:
```shell
$ cd systemd/centos/
$ docker build -t centos9-systemd --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 9.Dockerfile .
```

## Reference

- https://github.com/docker-library/docker/blob/master/dockerd-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/docker-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/Dockerfile-dind-rootless.template
- 

## Contact

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/leejjohnson/)
