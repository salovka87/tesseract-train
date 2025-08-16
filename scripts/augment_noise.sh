#!/usr/bin/env bash
# Přidá šum/blur/kontrast na syntetické obrázky (vyžaduje ImageMagick 'mogrify')
set -euo pipefail

SRC_DIR="${SRC_DIR:-./dataset/synth/train}"
OUT_DIR="${OUT_DIR:-./dataset/synth/train_aug}"
mkdir -p "$OUT_DIR"
shopt -s nullglob

for img in "$SRC_DIR"/*.tif; do
  base="$(basename "$img")"
  out="$OUT_DIR/${base%.tif}_aug.tif"
  convert "$img" -filter Gaussian -blur 0x0.5 -attenuate 0.03 +noise Gaussian -contrast-stretch 1%x1% "$out"
done
echo "Augmentace hotová v $OUT_DIR"
