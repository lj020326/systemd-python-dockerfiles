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

Intermediate container hashes are not supported as of Docker version 20.10. 
To view intermediate container hashes:

```shell
$ export DOCKER_BUILDKIT=0
```

To build image:
```shell
$ docker build -t redhat9-systemd-python --build-arg IMAGE_REGISTRY=media.johnson.int:5000 -f systemd/redhat/9.python.Dockerfile systemd/redhat/
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

### If getting TLS cert validation error for custom registry

BuildX for multiplatform builds runs in an own docker container and you will have to take extra steps 
to add trust to registries with self-signed certificates.

If getting TLS cert validation error using custom registry / cacerts when attempting to build using buildx container:

#### Option 1: configure buildx options to trust custom registry ca cert

1.  Create a buildkitd.toml and configure your private CA certificate:

```ini
[registry."your.dockerimagehost.example"]
  ca=["/home/downloads/mycacert.pem"]
```

2.  create a docker builder

```shell
docker buildx create --use --config buildkitd.toml
```

3.  then your build command should work

#### Option 2: add cert to buildx container (not recommended)

The following steps use the tool [update-ca-certificates](https://manpages.ubuntu.com/manpages/xenial/man8/update-ca-certificates.8.html) to get it done.

1.  Access the buildx container by opening a shell:
    
    ```
    docker exec -it buildx_buildkit_mybuilder0 /bin/sh
    ```
    
2.  Go to the trusted certificates folder
    
    ```
    cd /usr/local/share/ca-certificates/
    ```
    
3.  Copy the registry’s certificate from the source location the container e.g. by scp:
    
    ```
    scp &lt;username&gt;@&lt;sourceIP&gt;:/path/to/certificate/of/registry.crt \
        ./&lt;registrynameandport&gt;.crt
    ```
    
4.  Update the containers trusted CA list now by calling
    
    ```
    update-ca-certificates
    ```
    
    You can ignore the following warning, you might get
    
    > WARNING: ca-certificates.crt does not contain exactly one certificate or CRL: skipping
    
5.  Restart the builder container for the changes to take effect.
    

`docker build buildx` should work just fine now.

If unsure, you can verify if the process was successful by controlling the content of `/etc/ssl/certs` inside the buildx container. It should now contain an entry named `ca-cert-<registrynameandport>.pem` and it should also be listed in the `ca-certificates.crt` file.

A marginally more robust work-around, but still not pretty (no error checking etc):

```shell
BUILDER=$(sudo docker ps | grep buildkitd | cut -f1 -d' ')  
sudo docker cp YOUR-CA.crt $BUILDER:/usr/local/share/ca-certificates/  
sudo docker exec $BUILDER update-ca-certificates  
sudo docker restart $BUILDER

```

#### Option 3: Create custom buildkit container definition with custom ca cert added/trusted

Instead of mangling an existing builder container. driver-opt has a image option (for docker-container driver).

Have a 2 line Dockerfile that adds internal CAs to moby/buildkit and use that image when creating the builder.

To modify buildx builder image use `buildx create --driver-opt image=yourimage`


References:
- https://github.com/docker/buildx/tree/master/docs/reference
- https://github.com/docker/buildx/issues/80
- https://stackoverflow.com/questions/72894189/docker-buildx-build-failing-when-referring-repo-with-tls-certificate-signed-wi
- https://github.com/docker/buildx/blob/master/docs/guides/custom-registry-config.md

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
## to view intermediate hashes
$ export DOCKER_BUILDKIT=0
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