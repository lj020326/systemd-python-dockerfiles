[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-push-all-images.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-push-all-images.yml)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE)

# systemd-python docker images

The systemd-python enabled docker images defined here can be found on [dockerhub](https://hub.docker.com/repositories/lj020326?search=systemd).  

## Status

[![GitHub issues](https://img.shields.io/github/issues/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/issues)
[![GitHub stars](https://img.shields.io/github/stars/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/stargazers)
[![Docker Pulls - systemd-python-centos:8](https://img.shields.io/docker/pulls/lj020326/systemd-python-centos.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-centos/tags/8/)
[![Docker Pulls - systemd-python-centos:8](https://img.shields.io/docker/pulls/lj020326/systemd-python-centos.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-centos/tags/9/)
[![Docker Pulls - systemd-python-centos:8](https://img.shields.io/docker/pulls/lj020326/systemd-python-centos.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-centos/tags/10/)
[![Docker Pulls - systemd-python-redhat:8](https://img.shields.io/docker/pulls/lj020326/systemd-python-redhat.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-redhat/tags/8/)
[![Docker Pulls - systemd-python-redhat:9](https://img.shields.io/docker/pulls/lj020326/systemd-python-redhat.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-redhat/tags/9/)
[![Docker Pulls - systemd-python-ubuntu:2204](https://img.shields.io/docker/pulls/lj020326/systemd-python-ubuntu.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-ubuntu/tags/2204/)
[![Docker Pulls - systemd-python-debian:12](https://img.shields.io/docker/pulls/lj020326/systemd-python-debian.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/systemd-python-debian/tags/12/)

## Directory structure

- [aports-dev](./aports-dev) contains an image for Alpine Linux aports development.
- [openrc](./openrc) and [systemd](./systemd) contain init-enabled docker images in which services are able to run.

## Run molecule tests

The example below uses [ansible-datacenter molecule tests](https://github.com/lj020326/ansible-datacenter/tree/main/molecule)

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ ## NOTE: registry default is docker.io
$ export MOLECULE_IMAGE_REGISTRY=registry.example.int:5000
$ export MOLECULE_IMAGE_LABEL=systemd-python-redhat:7
$ molecule login
$ molecule --debug test -s bootstrap-linux-package
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=systemd-python-redhat:8 molecule --debug test -s bootstrap-linux-package
$ MOLECULE_IMAGE_LABEL=systemd-python-redhat:8 molecule login
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=systemd-python-redhat:8 molecule converge
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=systemd-python-centos:8 molecule --debug converge
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=systemd-python-ubuntu:2204 molecule --debug converge

```

To log into container

```shell
$ MOLECULE_IMAGE_LABEL=systemd-python-redhat:8 molecule create
$ MOLECULE_IMAGE_LABEL=systemd-python-redhat:8 molecule login
$ molecule destroy
```

To log into pure public docker images:
```shell
docker exec -it lj020326/centos9-systemd:latest bash
docker exec -it lj020326/systemd-python-centos:9:latest bash
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
$ docker run -d --name systemd-python-centos:9 --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro media.johnson.int:5000/systemd-python-centos:9
$ docker exec -it systemd-python-centos:9 bash
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


To build image from project root:
```shell
$ docker build -t systemd-python-redhat:9 \
  --build-arg IMAGE_REGISTRY=media.johnson.int:5000 \
  -f systemd/redhat/9.python.Dockerfile \
  systemd/redhat/
```

If you want to start a debug session when a build fails, you can use
`--on=error` to start a debug session when the build fails.

To build in debug mode:
```shell
$ export BUILDX_EXPERIMENTAL=1
$ docker buildx debug --on=error build -t systemd-python-redhat:9 \
  --build-arg IMAGE_REGISTRY=media.johnson.int:5000 \
  -f systemd/redhat/9.python.Dockerfile \
  systemd/redhat/
```

To build an image using centos9-systemd as an example:
```shell
$ cd centos/
$ docker build -t centos9-systemd --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 9.Dockerfile .
$ docker build -t systemd-python-centos:9 --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 9.python.Dockerfile .
$ cd ../debian
$ docker build -t systemd-python-debian:8 --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 8.python.Dockerfile .
```

### Running bash in image

To run bash in newly built image:

```shell
## if testing the locally built image
$ docker run --rm -it centos8-systemd bash -il
## if testing the image pushed to the registry
$ docker run --rm -it media.johnson.int:5000/centos8-systemd bash -il
```

## Reference

- https://github.com/docker-library/docker/blob/master/dockerd-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/docker-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/Dockerfile-dind-rootless.template
- 

## Contact

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/leejjohnson/)
