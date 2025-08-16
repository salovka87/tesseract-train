`dataset/` drží reálné i syntetické vzorky.

- `real/train/` a `real/val/`: sem dej své výřezy z faktur + stejnojmenné `.gt.txt` se správným textem.
- `synth/train/`: sem se vygenerují syntetické obrázky + `.box` (případně `.lstmf`).

Příklad:
```
dataset/real/train/header_001.tif
dataset/real/train/header_001.gt.txt
dataset/real/val/table_021.tif
dataset/real/val/table_021.gt.txt
```
