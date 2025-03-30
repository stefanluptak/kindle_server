FROM "hexpm/elixir:1.18.3-erlang-27.3-alpine-3.21.3"

RUN apk add --no-cache imagemagick fontconfig ttf-dejavu

RUN wget https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-unknown-linux-musl.tar.xz && \
    tar -C /usr/local/bin --strip-components=1 -xf typst-x86_64-unknown-linux-musl.tar.xz && \
    rm typst-x86_64-unknown-linux-musl.tar.xz

WORKDIR /workspace

ENV MIX_ENV=prod

COPY image.typ.eex .
COPY dashboard ./dashboard

RUN cd dashboard && mix deps.get

ENTRYPOINT ["/bin/sh", "-c", "mkdir -p images && cd dashboard && mix do deps.get, run -e \"Dashboard.new() |> Dashboard.render()\" && mv image.typ ../ && cd .. && typst compile --format png --ppi 72 image.typ images/image.png && magick images/image.png -colorspace Gray images/image.png"]
