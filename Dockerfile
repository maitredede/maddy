#syntax=docker/dockerfile:1
FROM golang:1.26-alpine AS build-env

ARG ADDITIONAL_BUILD_TAGS=""

RUN set -ex && \
    apk upgrade --no-cache --available && \
    apk add --no-cache git build-base

WORKDIR /maddy

COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN mkdir -p /pkg/data && \
    cp maddy.conf.docker /pkg/data/maddy.conf && \
    cp maddy.conf.docker-nonroot /pkg/data/maddy.conf.nonroot && \
    ./build.sh --builddir /tmp --destdir /pkg/ --tags "docker ${ADDITIONAL_BUILD_TAGS}" build install

FROM alpine:edge AS maddy-nonroot

RUN set -ex && \
    apk upgrade --no-cache --available && \
    apk --no-cache add ca-certificates
COPY --from=build-env /pkg/data/maddy.conf.nonroot /data/maddy.conf
COPY --from=build-env /pkg/usr/local/bin/maddy /bin/

EXPOSE 3025 3143 3993 3587 3465
VOLUME ["/data"]
ENTRYPOINT [ "/bin/maddy", "-config", "/data/maddy.conf"]
CMD ["run"]
USER 1001

FROM alpine:edge AS maddy
LABEL maintainer="fox.cpp@disroot.org"
LABEL org.opencontainers.image.source=https://github.com/foxcpp/maddy

RUN set -ex && \
    apk upgrade --no-cache --available && \
    apk --no-cache add ca-certificates
COPY --from=build-env /pkg/data/maddy.conf /data/maddy.conf
COPY --from=build-env /pkg/usr/local/bin/maddy /bin/

EXPOSE 25 143 993 587 465
VOLUME ["/data"]
ENTRYPOINT [ "/bin/maddy", "-config", "/data/maddy.conf", "-debug"]
CMD ["run"]
