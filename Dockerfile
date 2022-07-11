FROM bitnami/minideb as base

WORKDIR ${HOME}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -yy \
  sudo \
  bash \
  wget \
  curl \
  postfix \
  unzip \
  git \
  tini && \
  ln -sf /bin/bash /bin/sh && \
  rm -rf /var/lib/apt/lists/* && \
  echo 'export DEBIAN_FRONTEND=noninteractive' >/etc/profile.d/apt.sh && \
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

COPY --from=base / /

WORKDIR /root
VOLUME [ "/root","/config", "/data" ]

HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-debian.sh", "healthcheck" ]
ENTRYPOINT [ "tini", "-p", "SIGTERM", "--", "/usr/local/bin/entrypoint-debian.sh" ]
CMD [ "/bin/bash", "-c" ]
