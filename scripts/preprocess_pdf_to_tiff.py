#!/usr/bin/env python3
# Convert PDF -> high-DPI TIFF with cleaning and binarization (requires: wand/imagemagick or poppler + PIL/opencv).
# This is a template script with two backends:
# 1) ImageMagick/ghostscript via 'magick' CLI
# 2) poppler 'pdftoppm' + Python Pillow for postprocessing
# Pick the backend available on your system.

import os, sys, subprocess, tempfile, shutil
from pathlib import Path

def run_magick(pdf, out_dir, dpi=600):
    out_dir = Path(out_dir); out_dir.mkdir(parents=True, exist_ok=True)
    # Use 'magick' to render each page to TIFF, then clean: grayscale -> threshold -> despeckle
    # Adjust -threshold as needed per your invoices (try 60%-85%)
    cmd = [
        "magick", "-density", str(dpi), str(pdf),
        "-alpha", "remove", "-alpha", "off",
        "-colorspace", "Gray",
        "-threshold", "75%",
        "-despeckle",
        "-define", "tiff:rows-per-strip=8",
        str(out_dir / "page_%03d.tif")
    ]
    subprocess.check_call(cmd)

def main():
    if len(sys.argv) < 3:
        print("Usage: preprocess_pdf_to_tiff.py input.pdf output_dir [dpi=600]")
        sys.exit(1)
    pdf = Path(sys.argv[1])
    out = Path(sys.argv[2])
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 600
    run_magick(pdf, out, dpi=dpi)
    print(f"Done: {out}")

if __name__ == "__main__":
    main()
