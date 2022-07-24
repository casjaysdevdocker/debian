FROM bitnami/minideb as base

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'export DEBIAN_FRONTEND=noninteractive' >/etc/profile.d/apt.sh && \
  apt-get update && \
  install_packages \
  sudo \
  bash \
  wget \
  curl \
  postfix \
  unzip \
  git \
  tini && \
  update-alternatives --install /bin/sh sh /bin/bash 1 && \
  rm -rf /var/lib/apt/lists/* && \
  chmod 755 /etc/profile.d/apt.sh

COPY ./bin/. /usr/local/bin/

FROM scratch
ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')"

LABEL \
  org.label-schema.name="debian" \
  org.label-schema.description="Base Debian Linux" \
  org.label-schema.url="https://hub.docker.com/r/casjaysdevdocker/debian" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/debian" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="WTFPL" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="latest" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>"

COPY --from=base /. /

WORKDIR /root
VOLUME [ "/root","/config", "/data" ]

HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-debian.sh", "healthcheck" ]
ENTRYPOINT [  "tini", "-p", "SIGTERM", "--" ]
CMD [ "/usr/local/bin/entrypoint-debian.sh" ]

