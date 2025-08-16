#!/usr/bin/env bash
# Finetune z ces + font whitelist + variabilita
set -euo pipefail

MODEL_NAME="${MODEL_NAME:-oriogo}"
START_MODEL="${START_MODEL:-ces}"
TESSTRAIN_DIR="${TESSTRAIN_DIR:-./tesstrain}"
TESSDATA_DIR="${TESSDATA_DIR:-./tessdata_best}"
TRAINING_TEXT="${TRAINING_TEXT:-./data/oriogo_training_text.txt}"
WORDLIST_FILE="${WORDLIST_FILE:-./data/invoice_wordlist.txt}"
AMBIGS_FILE="${AMBIGS_FILE:-./data/ambigs.txt}"

FONT_WHITELIST="${FONT_WHITELIST:-}"
PTSIZE_MIN="${PTSIZE_MIN:-12}"
PTSIZE_MAX="${PTSIZE_MAX:-22}"
EXPOSURES="${EXPOSURES:-0 1 2}"
PSM="${PSM:-6}"
CHAR_SPACING_JITTER="${CHAR_SPACING_JITTER:-0.98,1.00,1.02}"
TEXT2IMAGE_EXTRA_ARGS="${TEXT2IMAGE_EXTRA_ARGS:-}"
FONTS_DIRS="${FONTS_DIRS:-/Library/Fonts:/System/Library/Fonts:/System/Library/Fonts/Supplemental:/usr/share/fonts:/usr/local/share/fonts}"

export TESSDATA_PREFIX="$TESSDATA_DIR"

command -v tesseract >/dev/null || { echo "Missing tesseract"; exit 1; }
command -v text2image >/dev/null || { echo "Missing text2image"; exit 1; }
[ -f "$TESSDATA_DIR/$START_MODEL.traineddata" ] || { echo "Need $TESSDATA_DIR/$START_MODEL.traineddata"; exit 1; }
[ -d "$TESSTRAIN_DIR" ] || { echo "Need tesstrain repo at $TESSTRAIN_DIR"; exit 1; }
[ -f "$TRAINING_TEXT" ] || { echo "Missing $TRAINING_TEXT"; exit 1; }
[ -f "$WORDLIST_FILE" ] || { echo "Missing $WORDLIST_FILE"; exit 1; }
[ -f "$AMBIGS_FILE" ] || { echo "Missing $AMBIGS_FILE"; exit 1; }

# Přidej NBSP, THIN SPACE, NARROW NBSP, FIGURE SPACE
printf "\nNBSP:\u00A0 NARROW_NBSP:\u202F THIN_SPACE:\u2009 FIGURE_SPACE:\u2007\n" >> "$TRAINING_TEXT"

MAKE_ARGS=(
  "TESSDATA=$TESSDATA_DIR"
  "TESSDATA_PREFIX=$TESSDATA_DIR"
  "START_MODEL=$START_MODEL"
  "MODEL_NAME=$MODEL_NAME"
  "LANG_TYPE=Latin"
  "TRAINING_TEXT=$(realpath "$TRAINING_TEXT")"
  "WORDLIST_FILE=$(realpath "$WORDLIST_FILE")"
  "AMBIGS_FILE=$(realpath "$AMBIGS_FILE")"
  "MAX_ITERATIONS=${MAX_ITERATIONS:-20000}"
  "PSM=$PSM"
  "FONTS_DIR=$FONTS_DIRS"
  "EXPOSURES=$EXPOSURES"
  "CHAR_SPACING_JITTER=$CHAR_SPACING_JITTER"
  "STEPS=FINETUNE"
)
[ -n "$FONT_WHITELIST" ] && MAKE_ARGS+=("FONTS=$FONT_WHITELIST")
[ -n "$PTSIZE_MIN" ] && MAKE_ARGS+=("PTSIZE_MIN=$PTSIZE_MIN")
[ -n "$PTSIZE_MAX" ] && MAKE_ARGS+=("PTSIZE_MAX=$PTSIZE_MAX")
[ -n "$TEXT2IMAGE_EXTRA_ARGS" ] && MAKE_ARGS+=("TEXT2IMAGE_EXTRA_ARGS=$TEXT2IMAGE_EXTRA_ARGS")

echo "==> tesstrain args:"
printf '    %q\n' "${MAKE_ARGS[@]}"
make -C "$TESSTRAIN_DIR" -j"$(sysctl -n hw.logicalcpu 2>/dev/null || nproc || echo 4)" "${MAKE_ARGS[@]}"

OUT_DIR="$TESSTRAIN_DIR/data/$MODEL_NAME"
if [ -f "$OUT_DIR/$MODEL_NAME.traineddata" ]; then
  cp -f "$OUT_DIR/$MODEL_NAME.traineddata" "./$MODEL_NAME.traineddata"
  echo "Built: $(pwd)/$MODEL_NAME.traineddata"
else
  echo "traineddata not found in $OUT_DIR"
  exit 1
fi
