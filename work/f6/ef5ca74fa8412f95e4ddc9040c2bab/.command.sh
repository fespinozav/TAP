#!/bin/bash -ue
mkdir -p results
bash check_pyspark.sh > results/pyspark_check.log 2>&1
