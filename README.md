[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-alpine.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-redhat.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-centos.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-fedora.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-fedora.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-ubuntu.yml)
[![Docker images build](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml/badge.svg)](https://github.com/lj020326/systemd-python-dockerfiles/actions/workflows/build-debian.yml)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE)

# systemd-python docker images

The systemd-python enabled docker images defined here can be found on [dockerhub](https://hub.docker.com/repositories/lj020326?search=systemd).  

## Status

[![GitHub issues](https://img.shields.io/github/issues/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/issues)
[![GitHub stars](https://img.shields.io/github/stars/lj020326/systemd-python-dockerfiles.svg?style=flat)](https://github.com/lj020326/systemd-python-dockerfiles/stargazers)
[![Docker Pulls - centos8-systemd-python](https://img.shields.io/docker/pulls/lj020326/centos8-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/centos8-systemd-python/)
[![Docker Pulls - centos8-systemd-python](https://img.shields.io/docker/pulls/lj020326/centos9-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/centos9-systemd-python/)
[![Docker Pulls - centos8-systemd-python](https://img.shields.io/docker/pulls/lj020326/centos10-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/centos10-systemd-python/)
[![Docker Pulls - redhat8-systemd-python](https://img.shields.io/docker/pulls/lj020326/redhat8-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/redhat8-systemd-python/)
[![Docker Pulls - redhat9-systemd-python](https://img.shields.io/docker/pulls/lj020326/redhat9-systemd-python.svg?style=flat)](https://hub.docker.com/repository/docker/lj020326/redhat9-systemd-python/)
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


To build image from project root:
```shell
$ docker build -t redhat9-systemd-python \
  --build-arg IMAGE_REGISTRY=media.johnson.int:5000 \
  -f systemd/redhat/9.python.Dockerfile \
  systemd/redhat/
```

If you want to start a debug session when a build fails, you can use
`--on=error` to start a debug session when the build fails.

To build in debug mode:
```shell
$ export BUILDX_EXPERIMENTAL=1
$ docker buildx debug --on=error build -t redhat9-systemd-python \
  --build-arg IMAGE_REGISTRY=media.johnson.int:5000 \
  -f systemd/redhat/9.python.Dockerfile \
  systemd/redhat/
```

To build an image using centos9-systemd as an example:
```shell
$ cd centos/
$ docker build -t centos9-systemd --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 9.Dockerfile .
$ docker build -t centos9-systemd-python --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 9.python.Dockerfile .
$ cd ../debian
$ docker build -t debian8-systemd-python --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 8.python.Dockerfile .
```

### Running bash in image

To run bash in newly built image:

```shell
## if testing the locally built image
$ docker run --rm -it centos8-systemd bash -il
## if testing the image pushed to the registry
$ docker run --rm -it media.johnson.int:5000/centos8-systemd bash -il
```

### Debugging failed build

When one of the Dockerfile build command fails, look for the **id of the preceding layer** and run a shell in a container created from that id:

```shell
$ docker run --rm -it centos8-systemd bash -il
$ docker run --rm -it centos8-systemd bash -il
$ docker run --rm -it <id_last_working_layer> bash -il
```

#### `on` flag

To start the debugger, first, ensure that `BUILDX_EXPERIMENTAL=1` is set in
your environment.

```shell
$ export BUILDX_EXPERIMENTAL=1
```

To view intermediate container hashes:

```shell
$ export DOCKER_BUILDKIT=0
```

If you want to start a debug session when a build fails, you can use
`--on=error` to start a debug session when the build fails.

```shell
$ export BUILDX_EXPERIMENTAL=1
$ docker buildx debug --on=error build .
$ docker buildx debug --on=error build -t debian8-systemd-python --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 8.python.Dockerfile .
```

UPDATE
Intermediate container hashes are not supported as of Docker version 20.10. 
To view intermediate container hashes:

```shell
$ DOCKER_BUILDKIT=0 docker build -t debian8-systemd-python --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f 8.python.Dockerfile .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            BuildKit is currently disabled; enable it by removing the DOCKER_BUILDKIT=0
            environment-variable.

Sending build context to Docker daemon  62.46kB
Step 1/25 : ARG IMAGE_REGISTRY=lj020326
Step 2/25 : FROM $IMAGE_REGISTRY/debian8-systemd:latest
 ---> e073c8665ceb
...
Step 20/25 : ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
 ---> Running in 51ebbfe0c1eb
 ---> Removed intermediate container 51ebbfe0c1eb
 ---> b1c595d36fc4
Step 21/25 : RUN CPPFLAGS="-I/usr/local/openssl/include -I/usr/local/openssl/include/openssl"     LDFLAGS="-L/usr/local/openssl/lib -L/usr/local/openssl/lib64"     pyenv install $PYTHON_VERSION
 ---> Running in 4253d5ef2e94
Downloading Python-3.11.7.tar.xz...
-> https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tar.xz
Installing Python-3.11.7...
Traceback (most recent call last):
  File "<string>", line 1, in <module>
  File "/pyenv/versions/3.11.7/lib/python3.11/ssl.py", line 100, in <module>
    import _ssl             # if we can't import it, let the error propagate
    ^^^^^^^^^^^
ModuleNotFoundError: No module named '_ssl'
ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?

Please consult to the Wiki page to fix the problem.
https://github.com/pyenv/pyenv/wiki/Common-build-problems


BUILD FAILED (Debian GNU/Linux 8 using python-build 20180424)

Inspect or clean up the working tree at /tmp/python-build.20240416133411.74
Results logged to /tmp/python-build.20240416133411.74.log

Last 10 log lines:
		$ensurepip --root=/ ; \
fi
Looking in links: /tmp/tmpo4sotjqo
Processing /tmp/tmpo4sotjqo/setuptools-65.5.0-py3-none-any.whl
Processing /tmp/tmpo4sotjqo/pip-23.2.1-py3-none-any.whl
Installing collected packages: setuptools, pip
  WARNING: The scripts pip3 and pip3.11 are installed in '/pyenv/versions/3.11.7/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed pip-23.2.1 setuptools-65.5.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
The command '/bin/sh -c CPPFLAGS="-I/usr/local/openssl/include -I/usr/local/openssl/include/openssl"     LDFLAGS="-L/usr/local/openssl/lib -L/usr/local/openssl/lib64"     pyenv install $PYTHON_VERSION' returned a non-zero code: 1
$ 
$ docker run --rm -it b1c595d36fc4 bash -il

```

Once in the container:

-   try the command that failed, and reproduce the issue
-   then fix the command and test it
-   finally update your Dockerfile with the fixed command

## Reference

- https://github.com/docker-library/docker/blob/master/dockerd-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/docker-entrypoint.sh
- https://github.com/docker-library/docker/blob/master/Dockerfile-dind-rootless.template
- 

## Contact

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/leejjohnson/)
