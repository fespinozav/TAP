#!/bin/bash -ue
mkdir -p results
echo -e "file	num_seq	total_len	gc_percent" > "results/summary.txt"

for f in GCA_000007385.1_ASM738v1_genomic.fna GCA_000008525.1_ASM852v1_genomic.fna GCA_000013525.1_ASM1352v1_genomic.fna GCA_000014305.1_ASM1430v1_genomic.fna GCA_000014325.1_ASM1432v1_genomic.fna; do
  bash "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/describe_fasta.sh" "$f" "tmp_summary.txt"
  tail -n +2 "tmp_summary.txt" >> "results/summary.txt"
done
