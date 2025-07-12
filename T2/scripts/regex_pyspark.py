#!/usr/bin/env python3
import argparse
from pyspark.sql import SparkSession
import re

p = argparse.ArgumentParser()
p.add_argument('--input',  required=True)
p.add_argument('--output', required=True)
args = p.parse_args()

spark = SparkSession.builder.appName("RegexSearch").getOrCreate()
sc = spark.sparkContext

files = sc.wholeTextFiles(args.input)
query = files.take(1)[0][1]
targets = files.map(lambda x: x[1]).collect()[1:]

results = []
for i, seq in enumerate(targets):
    cnt = len(re.findall(query.strip(), seq))
    results.append((i, cnt))

with open(args.output, 'w') as f:
    f.write("file_idx\tmatch_count\n")
    for i, cnt in results:
        f.write(f"{i}\t{cnt}\n")

spark.stop()