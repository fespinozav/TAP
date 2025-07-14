#!/bin/bash -ue
mkdir -p results
python3 "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/regex_pyspark.py"     --input "GCA_000007385.1_ASM738v1_genomic.fna"     --output "results/GCA_000007385.1_ASM738v1_genomic_regex.txt"
