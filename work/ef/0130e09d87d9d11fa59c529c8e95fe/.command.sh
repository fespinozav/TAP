#!/bin/bash -ue
mkdir -p results
echo -e "file	num_seq	total_len	gc_percent" > "results/summary.txt"

for f in GCA_000014325.1_ASM1432v1_genomic.fna; do
  bash "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/describe_fasta.sh" "$f" "tmp_summary.txt"
  tail -n +2 "tmp_summary.txt" >> "results/summary.txt"
done
