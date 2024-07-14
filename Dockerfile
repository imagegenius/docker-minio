FROM ghcr.io/imagegenius/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MINIO_VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    make \
    perl \
    git \
    go && \
  echo "**** install minio ****" && \
  mkdir -p \
    /tmp/minio && \
  if [ -z ${MINIO_VERSION+x} ]; then \
    MINIO_VERSION=$(curl -sL "https://api.github.com/repos/minio/minio/releases/latest" | jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/minio.tar.gz -L \
    "https://github.com/minio/minio/archive/${MINIO_VERSION}.tar.gz" && \
  tar xf \
    /tmp/minio.tar.gz -C \
    /tmp/minio --strip-components=1 && \
  cd /tmp/minio && \
  make install && \
  mv \
    /root/go/bin/minio \
    /usr/local/bin/minio && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /root/go

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9000 9001
VOLUME /config
