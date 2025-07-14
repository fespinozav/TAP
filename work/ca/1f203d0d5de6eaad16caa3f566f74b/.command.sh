#!/bin/bash -ue
mkdir -p results
python3 "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/regex_pyspark.py"     --input "GCA_000013525.1_ASM1352v1_genomic.fna"     --output "results/GCA_000013525.1_ASM1352v1_genomic_regex.txt"
