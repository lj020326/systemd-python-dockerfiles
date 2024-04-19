# Docker images for running systemd

You can use this images as base containers to run systemd services inside.

## Usage

1. Run the container as a daemon

`docker run -d --name systemd --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro jrei/$IMAGE`

or if it doesn't work

`docker run -d --name systemd --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro jrei/$IMAGE`

2. Enter to the container

`docker exec -it systemd sh`

3. Remove the container

`docker rm -f systemd`

## Building images

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

```console
$ export BUILDX_EXPERIMENTAL=1
```

If you want to start a debug session when a build fails, you can use
`--on=error` to start a debug session when the build fails.

```console
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

- https://stackoverflow.com/questions/26220957/how-can-i-inspect-the-file-system-of-a-failed-docker-build
- https://stackoverflow.com/a/66770818/8900478
- 