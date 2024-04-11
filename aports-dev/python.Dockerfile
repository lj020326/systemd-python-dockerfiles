#FROM alpine:edge
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/aports-dev:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2024041001"

COPY bash_profile /root/.bash_profile
COPY bashrc /root/.bashrc

COPY setup_pyenv.sh /root/setup_pyenv.sh
RUN  chmod +x /root/setup_pyenv.sh && /root/setup_pyenv.sh

ENTRYPOINT ["/sbin/init"]
