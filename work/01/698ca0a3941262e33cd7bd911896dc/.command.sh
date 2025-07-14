#!/bin/bash -ue
mkdir -p results
python3 "/Users/felipeespinoza/Documents/GitHub/TAP/scripts/regex_pyspark.py"     --input "GCA_000014325.1_ASM1432v1_genomic.fna"     --output "results/GCA_000014325.1_ASM1432v1_genomic_regex.txt"
