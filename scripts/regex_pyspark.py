#!/usr/bin/env python3

import argparse
import re
import os
from pyspark.sql import SparkSession

def main():
    # Parse arguments
    parser = argparse.ArgumentParser(
        description="Count occurrences of a k-mer in a target FASTA using PySpark")
    parser.add_argument('--pattern', required=True,
                        help="K-mer pattern string to search for")
    parser.add_argument('--input', required=True,
                        help="Path to target FASTA file")
    parser.add_argument('--output', required=True,
                        help="Path to write summary (file_idx, match_count)")
    args = parser.parse_args()

    # Initialize Spark
    spark = SparkSession.builder.appName("KmerCount").getOrCreate()
    sc = spark.sparkContext

    # Broadcast the k-mer pattern
    bpattern = sc.broadcast(args.pattern)

    # Read and concatenate the target FASTA sequence (skip header lines)
    fasta_rdd = sc.textFile(args.input) \
                  .filter(lambda line: not line.startswith('>'))
    seq = "".join(fasta_rdd.collect())

    # Count non-overlapping occurrences of the k-mer pattern
    count = len(re.findall(re.escape(bpattern.value), seq))

    # Ensure output directory exists
    out_dir = os.path.dirname(args.output)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    # Write results
    with open(args.output, 'w') as out:
        out.write("file_idx\tmatch_count\n")
        out.write(f"{os.path.basename(args.input)}\t{count}\n")

    spark.stop()

if __name__ == "__main__":
    main()