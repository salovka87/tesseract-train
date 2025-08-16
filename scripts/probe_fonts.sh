#!/usr/bin/env bash
# Zkusí vyrenderovat sentinel pro každý font ve whitelistu – odhalí chybějící glyfy
set -euo pipefail

SENTINEL_FILE="${SENTINEL_FILE:-./data/charset_sentinel.txt}"
FONTS="${FONT_WHITELIST:-Noto Sans,DejaVu Sans,Roboto,Open Sans,Arial,Times New Roman,Courier New}"
FONTS_DIRS="${FONTS_DIRS:-/Library/Fonts:/System/Library/Fonts:/System/Library/Fonts/Supplemental:/usr/share/fonts:/usr/local/share/fonts}"
OUT_DIR="${OUT_DIR:-./tmp_font_probe}"
RESOLUTION="${RESOLUTION:-300}"
PTSIZE="${PTSIZE:-16}"

mkdir -p "$OUT_DIR"
IFS=',' read -r -a FONT_ARR <<< "$FONTS"
ok=0; fail=0
for font in "${FONT_ARR[@]}"; do
  font=$(echo "$font" | sed 's/^ *//;s/ *$//')
  base="$OUT_DIR/$(echo "$font" | tr ' /' '__')"
  if text2image --fonts_dir="$FONTS_DIRS" --font="$font" --text="$SENTINEL_FILE" --outputbase="$base" --resolution="$RESOLUTION" --ptsize="$PTSIZE" --strip_unrenderable_words >/dev/null 2>&1; then
    echo "OK  : $font"
    ok=$((ok+1))
  else
    echo "FAIL: $font (některé glyfy chybí?)"
    fail$((fail+1)) 2>/dev/null || true
  fi
done
echo "Summary: OK=$ok FAIL=$fail (viz $OUT_DIR)"
