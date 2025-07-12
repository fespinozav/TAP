import time
import pandas as pd
import time
import glob
import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, udf, length
from pyspark.sql.types import StringType, IntegerType

# Inicializar Spark
spark = SparkSession.builder.appName("FASTA_Kmer_Matching").getOrCreate()
sc = spark.sparkContext

path_obj = os.path.join(os.getcwd(), 'files', 'genome_ref')
files_path = os.path.join(os.getcwd(), 'files', 'genomes')
fasta_obj = os.path.join(path_obj, 'GCF_003119375.1_ASM311937v1_genomic.fna')

df_path = pd.DataFrame(os.listdir(files_path), columns=['filename'])

records = []

for file in df_path['filename']:
    if not file.endswith('.fna'):
        continue

    print(f"Processing file: {file}")
    file_path = os.path.join(files_path, file)
    with open(file_path) as f:
        header = f.readline().strip()
        genome = "".join(line.strip() for line in f if not line.startswith(">"))

    # Acumula en lista
    records.append({
        'filename': file,
        'seq_header': header,
        'genome': genome
    })

with open(fasta_obj) as f:
        header = f.readline().strip()
        genome_obj = "".join(line.strip() for line in f if not line.startswith(">"))

# Tamaño de k-mers
k = 2
def kmers(seq: str, k: int):
    return [ seq[i : i + k] 
             for i in range(len(seq) - k + 1) ]

def build_kmer_index(genome: str, k: int):
    index = {}
    for i in range(len(genome) - k + 1):
        kmer = genome[i:i+k]
        index.setdefault(kmer, []).append(i)
    return index

def process_read(seq: str):
    kmer_list = kmers(seq, k)
    t0 = time.time()
    sum_cal = 0
    all_pos = []
    for mer in kmer_list:
        positions = genome_index_bc.value.get(mer, [])
        if positions:
            sum_cal += len(positions)
            all_pos.extend(positions)
    dt = time.time() - t0
    return {"Sequence": seq[:30] + "...", "Sum_Cal": sum_cal, "Positions": all_pos, "Time(s)": dt}

# Crear DataFrame de Pandas con los registros
df_genome = pd.DataFrame(records)
reads_rdd = sc.parallelize(df_genome['genome'].tolist())

genome_index = build_kmer_index(genome_obj, k)
genome_index_bc = sc.broadcast(genome_index)

reads_rdd = reads_rdd.repartition(8)  # ajusta el número a los núcleos disponibles

df_results = spark.createDataFrame(reads_rdd.map(process_read))
df_results.toPandas().to_csv('results/output.csv', index=False, encoding='utf-8')

print("El archivo output.csv ha sido creado con éxito.")