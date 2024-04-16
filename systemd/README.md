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

### Debugging failed build

When one of the Dockerfile build command fails, look for the **id of the preceding layer** and run a shell in a container created from that id:

```shell
$ docker run --rm -it <id_last_working_layer> bash -il
```

Once in the container:

-   try the command that failed, and reproduce the issue
-   then fix the command and test it
-   finally update your Dockerfile with the fixed command
