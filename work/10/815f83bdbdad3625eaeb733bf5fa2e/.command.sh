#!/bin/bash -ue
mkdir -p results
python3 "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/regex_pyspark.py"     --input "GCA_000008525.1_ASM852v1_genomic.fna"     --output "results/GCA_000008525.1_ASM852v1_genomic_regex.txt"
