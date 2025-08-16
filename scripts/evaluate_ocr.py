#!/usr/bin/env python3
# Evaluate CER/WER on dataset/real/val using tesseract and .gt.txt
import os, subprocess, sys, difflib
from pathlib import Path

def norm(s):
  return s.replace("\r\n","\n").replace("\r","\n")

def edit_distance(a,b):
  # Levenshtein via dynamic programming (no external deps)
  la, lb = len(a), len(b)
  dp = [[0]*(lb+1) for _ in range(la+1)]
  for i in range(la+1): dp[i][0]=i
  for j in range(lb+1): dp[0][j]=j
  for i in range(1,la+1):
    for j in range(1,lb+1):
      cost = 0 if a[i-1]==b[j-1] else 1
      dp[i][j] = min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1]+cost)
  return dp[la][lb]

def cer(ref, hyp):
  ref_chars = "".join(ref.split())
  hyp_chars = "".join(hyp.split())
  if not ref_chars: return 0.0
  d = edit_distance(ref_chars, hyp_chars)
  return d/len(ref_chars)

def wer(ref, hyp):
  ref_words = ref.split()
  hyp_words = hyp.split()
  if not ref_words: return 0.0
  # simple Levenshtein on words
  la, lb = len(ref_words), len(hyp_words)
  dp = [[0]*(lb+1) for _ in range(la+1)]
  for i in range(la+1): dp[i][0]=i
  for j in range(lb+1): dp[0][j]=j
  for i in range(1,la+1):
    for j in range(1,lb+1):
      cost = 0 if ref_words[i-1]==hyp_words[j-1] else 1
      dp[i][j] = min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1]+cost)
  return dp[la][lb]/len(ref_words)

def run_ocr(img_path, model="oriogo"):
  outbase = img_path.with_suffix("")
  cmd = ["tesseract", str(img_path), str(outbase), "-l", model, "--psm", "6", "--oem", "1"]
  subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  txt_path = outbase.with_suffix(".txt")
  return txt_path.read_text(encoding="utf-8", errors="ignore")

def main():
  model = sys.argv[1] if len(sys.argv)>1 else "oriogo"
  val_dir = Path("dataset/real/val")
  if not val_dir.exists():
    print("dataset/real/val not found")
    sys.exit(1)
  imgs = sorted([p for p in val_dir.glob("*.*") if p.suffix.lower() in (".tif",".tiff",".png",".jpg",".jpeg")])
  if not imgs:
    print("No images in dataset/real/val")
    sys.exit(0)

  total_cer = 0.0
  total_wer = 0.0
  n=0
  for img in imgs:
    gt = img.with_suffix(".gt.txt")
    if not gt.exists(): 
      print(f"Skip {img.name} (missing .gt.txt)")
      continue
    ref = norm(gt.read_text(encoding="utf-8", errors="ignore"))
    hyp = norm(run_ocr(img, model=model))
    c = cer(ref,hyp); w = wer(ref,hyp)
    print(f"{img.name}: CER={c:.3%}  WER={w:.3%}")
    total_cer += c; total_wer += w; n+=1

  if n>0:
    print(f"\nAVG CER={total_cer/n:.3%}  AVG WER={total_wer/n:.3%}  (n={n})")

if __name__=="__main__":
  main()
