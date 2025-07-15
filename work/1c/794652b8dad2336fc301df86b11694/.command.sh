#!/bin/bash -ue
mkdir -p results
echo -e "file_idx	match_count" > "results/regex_summary.txt"

for f in /Users/felipeespinoza/Documents/GitHub/TAP/work/d2/8f53fe209eb4915323a8cddf818adb/data/GCA_000007385.1_ASM738v1_genomic.fna /Users/felipeespinoza/Documents/GitHub/TAP/work/d2/8f53fe209eb4915323a8cddf818adb/data/GCA_000008525.1_ASM852v1_genomic.fna /Users/felipeespinoza/Documents/GitHub/TAP/work/d2/8f53fe209eb4915323a8cddf818adb/data/GCA_000013525.1_ASM1352v1_genomic.fna /Users/felipeespinoza/Documents/GitHub/TAP/work/d2/8f53fe209eb4915323a8cddf818adb/data/GCA_000014305.1_ASM1430v1_genomic.fna /Users/felipeespinoza/Documents/GitHub/TAP/work/d2/8f53fe209eb4915323a8cddf818adb/data/GCA_000014325.1_ASM1432v1_genomic.fna; do
  python3 "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/regex_pyspark.py" --pattern "GC" --input "$f" --output "results/tmp_regex.txt"
  tail -n +2 "results/tmp_regex.txt" >> results/regex_summary.txt
done
