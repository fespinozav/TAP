#!/bin/bash -ue
mkdir -p results/plots
python3 - << 'PYCODE'
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import glob
import sys

# Leer y concatenar summaries
summary_paths = glob.glob('summary.txt')
dfs = []
for p in summary_paths:
    df = pd.read_csv(p, sep='\t', header=0)
    df.rename(columns={
        'file': 'filename',
        'num_seq': 'num_sequences',
        'total_len': 'total_length'
    }, inplace=True)
    dfs.append(df)
summary_df = pd.concat(dfs, ignore_index=True)

# Exit if no summary data
if summary_df.empty:
    print("No summary data available, skipping plots.")
    sys.exit(0)

# Ensure numeric types
summary_df['num_sequences'] = pd.to_numeric(summary_df['num_sequences'], errors='coerce')
summary_df['total_length'] = pd.to_numeric(summary_df['total_length'], errors='coerce')
if 'gc_percent' in summary_df.columns:
    summary_df['gc_percent'] = pd.to_numeric(summary_df['gc_percent'], errors='coerce')

# Número de secuencias
plt.figure(figsize=(10, 6))
ax = summary_df.plot(x='filename', y='num_sequences', kind='bar', legend=False)
plt.savefig('results/plots/num_sequences.png')
ax.set_title('Número de Secuencias')
ax.set_xlabel('Archivo')
ax.set_ylabel('Número de Secuencias')
ax.tick_params(axis='x', rotation=45, labelsize=8)
plt.tight_layout()
plt.savefig('results/plots/num_sequences.png')

# Longitud total
plt.figure(figsize=(10, 6))
ax = summary_df.plot(x='filename', y='total_length', kind='bar', legend=False)
ax.set_title('Longitud Total de Genomas')
ax.set_xlabel('Archivo')
ax.set_ylabel('Longitud Total (bp)')
ax.tick_params(axis='x', rotation=45, labelsize=8)
plt.tight_layout()
plt.savefig('results/plots/total_length.png')

# GC Content plot
if 'gc_percent' in summary_df.columns:
    plt.figure(figsize=(10, 6))
    ax = summary_df.plot(x='filename', y='gc_percent', kind='bar', legend=False)
    ax.set_title('Contenido GC (%)')
    ax.set_xlabel('Archivo')
    ax.set_ylabel('GC (%)')
    ax.tick_params(axis='x', rotation=45, labelsize=8)
    plt.tight_layout()
    plt.savefig('results/plots/gc_content.png')

# Leer el resumen consolidado de regex
regex_path = 'regex_summary.txt'
rdf = pd.read_csv(regex_path, sep='\t', header=0)
rdf.rename(columns={'file_idx':'filename'}, inplace=True)

# Ensure numeric type
rdf['match_count'] = pd.to_numeric(rdf['match_count'], errors='coerce')

# Conteo de matches
plt.figure(figsize=(10, 6))
ax = rdf.plot(x='filename', y='match_count', kind='bar', legend=False)
ax.set_title('Conteo de Matches por Regex')
ax.set_xlabel('Archivo')
ax.set_ylabel('Matches')
ax.tick_params(axis='x', rotation=45, labelsize=8)
plt.tight_layout()
plt.savefig('results/plots/regex_counts.png')
PYCODE
