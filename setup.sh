#!/usr/bin/env bash
set -e

echo "🚀 Instalace Tesseract a Python prostředí..."

# Instalace pro Ubuntu/Debian
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y tesseract-ocr tesseract-ocr-ces tesseract-ocr-eng         libleptonica-dev libtesseract-dev pkg-config python3 python3-pip
fi

# Instalace pro macOS (Homebrew)
if command -v brew >/dev/null 2>&1; then
    brew install tesseract
fi

# Python balíčky
pip3 install --upgrade pip
pip3 install -r requirements.txt

echo "✅ Instalace dokončena."
tesseract --version
