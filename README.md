[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml)
[![License](https://img.shields.io/badge/license-GPLv3-brightgreen.svg?style=flat)](LICENSE)

# This repository contains systemd enabled dockerfiles

Image builds are triggered automatically each month.

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


## License

Copyright (c) 2019-2022 Lee Johnson - GNU License

## Contact

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/leejjohnson/)
