FROM elixir:1.14.1-alpine as build

ENV MIX_ENV=prod

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev

WORKDIR /pleroma

COPY ../pleroma /pleroma

RUN echo "import Mix.Config" > config/prod.secret.exs \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mkdir release \
    && mix release --path release


FROM alpine:3.16.3

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="ops@pleroma.social" \
    org.opencontainers.image.title="pleroma" \
    org.opencontainers.image.description="Pleroma for Docker" \
    org.opencontainers.image.authors="ops@pleroma.social" \
    org.opencontainers.image.vendor="pleroma.social" \
    org.opencontainers.image.documentation="https://git.pleroma.social/pleroma/pleroma" \
    org.opencontainers.image.licenses="AGPL-3.0" \
    org.opencontainers.image.url="https://pleroma.social" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.source=https://github.com/mirror-kt/docker-pleroma

ARG HOME=/opt/pleroma
ARG DATA=/var/lib/pleroma

RUN apk update &&\
    apk add exiftool ffmpeg imagemagick libmagic ncurses postgresql-client su-exec shadow &&\
    mkdir -p ${DATA}/uploads &&\
    mkdir -p ${DATA}/static &&\
    mkdir -p /etc/pleroma

COPY --from=build /pleroma/release ${HOME}

COPY --from=build /pleroma/config/docker.exs /etc/pleroma/config.exs
COPY --from=build /pleroma/docker-entrypoint.sh ${HOME}

COPY ./entrypoint-wrapper.sh ${HOME}

EXPOSE 4000

ENTRYPOINT ["/opt/pleroma/entrypoint-wrapper.sh"]

