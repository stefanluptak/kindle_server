#! /usr/bin/env sh

set -eu

mkdir -p images
cd dashboard
mix do deps.get
mix run -e "Dashboard.new() |> Dashboard.render()"
cd ..
mv dashboard/image.typ .
typst compile --format png --ppi 72 image.typ images/image.png
magick images/image.png -colorspace Gray images/image.png
magick images/image.png -rotate 90 images/image.png
