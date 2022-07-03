FROM alpine:edge

RUN apk add --update --upgrade --no-cache --force-overwrite alpine-sdk
RUN echo 'dev    ALL=(ALL) ALL' >> /etc/sudoers
RUN adduser dev -u 1000 -DG abuild
RUN su dev -c 'abuild-keygen -an'
RUN cat /home/dev/.abuild/abuild.conf > /etc/abuild.conf

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

USER dev
