FROM elixir:1.14.1-alpine as build

ENV MIX_ENV=prod

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev

WORKDIR /akkoma

COPY ./akkoma /akkoma

RUN echo "import Mix.Config" > config/prod.secret.exs \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mkdir release \
    && mix release --path release


FROM alpine:3.16.3

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="ops@akkoma.social" \
    org.opencontainers.image.title="akkoma" \
    org.opencontainers.image.description="Akkoma for Docker" \
    org.opencontainers.image.vendor="akkoma.dev" \
    org.opencontainers.image.documentation="https://docs.akkoma.dev/stable/" \
    org.opencontainers.image.licenses="AGPL-3.0" \
    org.opencontainers.image.url="https://akkoma.dev" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.source=https://github.com/mirror-kt/docker-akkoma

ARG HOME=/opt/akkoma
ARG DATA=/var/lib/akkoma

RUN apk update &&\
    apk add exiftool ffmpeg imagemagick libmagic ncurses postgresql-client su-exec shadow &&\
    mkdir -p ${DATA}/uploads &&\
    mkdir -p ${DATA}/static &&\
    mkdir -p /etc/akkoma

COPY --from=build /akkoma/release ${HOME}

COPY --from=build /akkoma/config/docker.exs /etc/akkoma/config.exs
COPY --from=build /akkoma/docker-entrypoint.sh ${HOME}

COPY ./entrypoint-wrapper.sh ${HOME}

EXPOSE 4000

ENTRYPOINT ["/opt/akkoma/entrypoint-wrapper.sh"]

