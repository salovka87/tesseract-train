# ORIOGO Invoice OCR Training Pack

Cíl: vyrobit `oriogo.traineddata` (finetune z `ces`) s rozšířeným unicharsetem a realistickým datasetem na faktury.

## Složky
- `data/` – tréninkový text, wordlisty, sentinel znaky, seznam povinných znaků.
- `dataset/` – šablona struktury pro reálné i syntetické vzorky.
- `scripts/` – trénink (tesstrain), generování syntetiky, ověření charsetu, evaluace (CER/WER), augmentace.
- `tessdata_best/` – _sem vlož `ces.traineddata`_.
- `.github/workflows/` – CI kontrola (verify charset), neplést s plným tréninkem.
- `Makefile` – hlavní cíle: `train`, `verify`, `gen-synth`, `augment`, `eval`, `clean`.

## Rychlý start
1. Do `tessdata_best/` dej `ces.traineddata` (best).
2. Naklonuj `tesstrain` vedle tohoto balíčku, nebo nastav `TESSTRAIN_DIR` env proměnnou.
3. Nastav fonty (doporučeno Noto/DejaVu + kancelářské). Připrav whitelist (`FONT_WHITELIST`).
4. Spusť:
   ```bash
   make train
   make verify
   ```
5. (Volitelně) vygeneruj syntetiku: `make gen-synth` a přidej *reálné výřezy* do `dataset/real/**`.

## Tipy
- Pro kvalitu přidej reálné výřezy (TIFF/PNG + `.gt.txt`).
- Použij `FONT_WHITELIST` (viz `scripts/train_oriogo_tesstrain_plus.sh`).
- Kontrolu pokrytí dělej po každém tréninku: `make verify`.
