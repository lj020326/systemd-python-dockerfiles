#FROM alpine:latest
ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/openrc-alpine:latest

LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2024041001"

ARG USERNAME=container-user
ARG GROUPNAME=container-user
ARG USER_UID=1000
ARG GROUP_GID=1000

## ref: https://stackoverflow.com/questions/49955097/how-do-i-add-a-user-when-im-using-alpine-as-a-base-image
RUN if getent passwd ${USER_UID} >/dev/null; then \
    deluser $(getent passwd ${USER_UID} | cut -d: -f1); fi

RUN if getent group ${GROUP_GID} >/dev/null; then \
    delgroup $(getent group ${GROUP_GID} | cut -d: -f1); fi

RUN addgroup --system --gid ${GROUP_GID} ${GROUPNAME}

RUN adduser --system --disabled-password --home /home/${USERNAME} \
    --uid ${USER_UID} --ingroup ${GROUPNAME} ${GROUPNAME} \

#RUN adduser ${USERNAME} -u ${USER_UID} -DG ${GROUPNAME}
#RUN su ${USERNAME} -c ${GROUPNAME}-keygen -an
#RUN echo "${USERNAME}    ALL=(ALL) ALL" >> /etc/sudoers
#RUN cat /home/${USERNAME}/.${GROUPNAME}/${GROUPNAME}.conf > /etc/${GROUPNAME}.conf

USER ${USERNAME}

COPY bash_profile /home/${USERNAME}/.bash_profile
COPY bashrc /home/${USERNAME}/.bashrc

COPY setup_pyenv.sh /home/${USERNAME}/setup_pyenv.sh
RUN  chmod +x /home/${USERNAME}/setup_pyenv.sh && /home/${USERNAME}/setup_pyenv.sh

ENTRYPOINT ["/sbin/init"]
