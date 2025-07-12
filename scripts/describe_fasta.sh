#!/usr/bin/env bash
infile=$1
outfile=$2

num_seq=$(grep -c '^>' "$infile")
total_len=$(grep -v '^>' "$infile" | tr -d '\n' | wc -c)
gc=$(grep -v '^>' "$infile" | tr -d '\n' | grep -o '[GgCc]' | wc -l)
gc_pct=$(awk "BEGIN{printf \"%.2f\", $gc*100/$total_len}")

echo -e "file\tnum_seq\ttotal_len\tgc_pct" > "$outfile"
echo -e "$(basename $infile)\t$num_seq\t$total_len\t$gc_pct" >> "$outfile"