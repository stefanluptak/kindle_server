FROM "hexpm/elixir:1.18.3-erlang-27.3-alpine-3.21.3"

RUN apk add --no-cache imagemagick

RUN wget https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-unknown-linux-musl.tar.xz && \
    tar -C /usr/local/bin --strip-components=1 -xf typst-x86_64-unknown-linux-musl.tar.xz && \
    rm typst-x86_64-unknown-linux-musl.tar.xz

WORKDIR /workspace

ENV MIX_HOME=/opt/mix

RUN elixir -e 'Mix.install([:tzdata])'

COPY image.typ.eex .
COPY script.exs .

ENTRYPOINT ["/bin/sh", "-c", "mkdir -p images && elixir script.exs && typst compile --format png image.typ images/image.png && magick images/image.png -colorspace Gray images/image.png"]
