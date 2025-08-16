# GitHub Workflows Overview

- **codex-bootstrap.yml** — připraví základ repo strukturu, aby „Code/Codex“ mohl vytvářet úlohy/PR.
- **verify.yml** — lehká sanity kontrola.
- **train-selfhosted.yml** — plnohodnotný trénink na self-hosted runneru (doporučeno).
- **train-ubuntu.yml** — omezený demo trénink na ubuntu-latest (spíš pro test integrace).
- **preprocess_dataset.yml** — PDF/PNG → TIFF (ImageMagick), 600 DPI default.
- **gen_synth.yml** — generuje syntetická data přes `scripts/gen_synthetic_dataset.sh`.
- **validate_model.yml** — spočítá CER/WER na `dataset/real/val` pomocí `scripts/evaluate_ocr.py`.
- **release.yml** — vytvoří GitHub Release a přiloží `oriogo.traineddata`.

> Tyto workflowy předpokládají, že v repu jsou skripty z „Oriogo Invoice Training Pack“ (`scripts/…`, `data/…`). Pokud je ještě nemáš, nahraj je nebo požádej Codex, ať je doplní.
