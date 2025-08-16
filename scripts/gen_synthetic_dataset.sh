#!/usr/bin/env bash
# Vygeneruje syntetické TIFF + BOX z training_text (pro každý font/ptsize/exposure)
set -euo pipefail

OUT_DIR="${OUT_DIR:-./dataset/synth/train}"
TRAINING_TEXT="${TRAINING_TEXT:-./data/oriogo_training_text.txt}"
FONTS="${FONT_WHITELIST:-Noto Sans,DejaVu Sans,Roboto,Open Sans,Arial,Times New Roman,Courier New}"
PTSIZE_MIN="${PTSIZE_MIN:-12}"
PTSIZE_MAX="${PTSIZE_MAX:-22}"
EXPOSURES="${EXPOSURES:-0 1 2}"
FONTS_DIRS="${FONTS_DIRS:-/Library/Fonts:/System/Library/Fonts:/System/Library/Fonts/Supplemental:/usr/share/fonts:/usr/local/share/fonts}"
RESOLUTION="${RESOLUTION:-300}"

mkdir -p "$OUT_DIR"

IFS=',' read -r -a FONT_ARR <<< "$FONTS"
i=0
for font in "${FONT_ARR[@]}"; do
  font=$(echo "$font" | sed 's/^ *//;s/ *$//')
  for size in $(seq "$PTSIZE_MIN" "$PTSIZE_MAX"); do
    for exp in $EXPOSURES; do
      base=$(printf "%s/font_%02d_pt%02d_exp%s" "$OUT_DIR" $i $size "$exp")
      text2image \
        --fonts_dir="$FONTS_DIRS" \
        --font="$font" \
        --text="$TRAINING_TEXT" \
        --outputbase="$base" \
        --resolution="$RESOLUTION" \
        --exposure="$exp" \
        --ptsize="$size" \
        --max_pages=1 \
        --strip_unrenderable_words \
        --leading=32 \
        --char_spacing=1.0 \
        --unicharset_output="$base.unicharset" \
        >/dev/null 2>&1 || true
    done
  done
  i=$((i+1))
done

echo "Done. Check $OUT_DIR for .tif and .box"
