# Main entry points
SHELL := /bin/bash

export TESSTRAIN_DIR ?= ./tesstrain
export TESSDATA_DIR  ?= ./tessdata_best
export FONT_WHITELIST ?= Noto Sans,DejaVu Sans,Roboto,Open Sans,Arial,Times New Roman,Courier New

train:
	@./scripts/train_oriogo_tesstrain_plus.sh

verify:
	@./scripts/verify_charset.sh oriogo ./data/required_chars.txt

gen-synth:
	@./scripts/gen_synthetic_dataset.sh

augment:
	@./scripts/augment_noise.sh

probe-fonts:
	@./scripts/probe_fonts.sh

eval:
	@./scripts/evaluate_ocr.py oriogo

clean:
	@rm -f oriogo.traineddata oriogo.*
	@rm -rf tmp_font_probe
