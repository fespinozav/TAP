#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Staging del script de descarga en el workdir
download_ch = Channel.fromPath('scripts/download_data.sh')

// Parámetros
//params.genome_dir = params.genome_dir ?: 'files/genomes'
params.genome_dir = 'files/genomes'
//fastas_ch = Channel.fromPath("$params.genome_dir/files/genomes/*.fna").ifEmpty { error "No FASTA files found in $params.genome_dir/files/genomes" }
check_script = Channel.fromPath('scripts/check_pyspark.sh')



params.results = 'results'

// --------------------------------------------------
// PROCESO: DOWNLOAD
// Descarga archivos FASTA a files/genomes
// --------------------------------------------------

  process DOWNLOAD {
    label 'download'
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
      file download_data
      val genome_dir

    output:
      path "${genome_dir}/*.fna", emit: fastas

    script:
    """
    bash ${download_data} ${genome_dir}
    """
  }

// --------------------------------------------------
// PROCESO: DESCRIBE_FASTA
// Genera un resumen de cada archivo FASTA  
// --------------------------------------------------

process DESCRIBE_FASTA {
  label 'describe'

  input:
    path fasta_file

  
  output:
    path "${params.results}/${fasta_file.baseName}_summary.txt", emit: summaries

  script:
  """
  mkdir -p ${params.results}
  bash "${workflow.projectDir}/scripts/describe_fasta.sh" "${fasta_file}" "${params.results}/${fasta_file.baseName}_summary.txt"
  """
}

// --------------------------------------------------
// PROCESO: REGEX_PYSPARK
// Busca un patrón con PySpark en cada FASTA
// --------------------------------------------------
process REGEX_PYSPARK {
  label 'regex'

  input:
    path fasta_file

  output:
    path "${params.results}/${fasta_file.baseName}_regex.txt", emit: regex_out

  script:
  """
  mkdir -p ${params.results}
  python3 "${workflow.projectDir}/scripts/regex_pyspark.py" \
    --input "${fasta_file}" \
    --output "${params.results}/${fasta_file.baseName}_regex.txt"
  """
}

// --------------------------------------------------
// PROCESO: CHECK_PYSPARK
// Verifica e instala PySpark si hace falta
// --------------------------------------------------
process CHECK_PYSPARK {
  label 'check'

  input:
    file check_script

  output:
    path "${params.results}/pyspark_check.log", emit: check_log

  script:
  """
  mkdir -p ${params.results}
  bash ${check_script} > ${params.results}/pyspark_check.log 2>&1
  """
}

// --------------------------------------------------
// PROCESO: PLOT
// Genera gráficos a partir de los resultados
// --------------------------------------------------
process PLOT {
  label 'plot'
  publishDir "${params.results}/plots", mode: 'copy'

  // Toma todos los summaries y regex outputs
  input:
    path summary_files
    path regex_files
  
  output:
    path "${params.results}/plots"
  
  script:
  """
  mkdir -p ${params.results}/plots
  python3 - << 'PYCODE'
  import pandas as pd
  import matplotlib.pyplot as plt
  import matplotlib.ticker as ticker
  import glob
  import sys

  # Leer y concatenar summaries
  summary_paths = glob.glob('*_summary.txt')
  dfs = []
  for p in summary_paths:
      df = pd.read_csv(p, sep='\\t', header=0)
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
  plt.savefig('${params.results}/plots/num_sequences.png')
  ax.set_title('Número de Secuencias')
  ax.set_xlabel('Archivo')
  ax.set_ylabel('Número de Secuencias')
  ax.tick_params(axis='x', rotation=45, labelsize=8)
  plt.tight_layout()
  plt.savefig('${params.results}/plots/num_sequences.png')

  # Longitud total
  plt.figure(figsize=(10, 6))
  ax = summary_df.plot(x='filename', y='total_length', kind='bar', legend=False)
  ax.set_title('Longitud Total de Genomas')
  ax.set_xlabel('Archivo')
  ax.set_ylabel('Longitud Total (bp)')
  ax.tick_params(axis='x', rotation=45, labelsize=8)
  plt.tight_layout()
  plt.savefig('${params.results}/plots/total_length.png')

  # GC Content plot
  if 'gc_pct' in summary_df.columns:
      plt.figure(figsize=(10, 6))
      ax = summary_df.plot(x='filename', y='gc_pct', kind='bar', legend=False)
      ax.set_title('Contenido GC (%)')
      ax.set_xlabel('Archivo')
      ax.set_ylabel('GC (%)')
      ax.tick_params(axis='x', rotation=45, labelsize=8)
      plt.tight_layout()
      plt.savefig('${params.results}/plots/gc_content.png')

  # Leer y concatenar regex counts
  regex_paths = glob.glob('*_regex.txt')
  rdfs = []
  for p in regex_paths:
      rdf = pd.read_csv(p, sep='\\t', header=0)
      rdf.rename(columns={'file_idx':'filename'}, inplace=True)
      rdfs.append(rdf)
  rdf = pd.concat(rdfs, ignore_index=True)
  # Exit or skip if no regex data
  if rdf.empty:
      print("No regex data available, skipping regex plot.")
      sys.exit(0)
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
  plt.savefig('${params.results}/plots/regex_counts.png')
  PYCODE
  """
}





workflow {
  // Ejecutar descarga y usar su salida como canal de FASTA
  fastas_list = DOWNLOAD(download_ch, params.genome_dir).flatten()
  fastas      = fastas_list.flatten()
  
  // Describir FASTA
  summaries = DESCRIBE_FASTA(fastas)
  regex_out = REGEX_PYSPARK(fastas)
  
  // Verificar PySpark
  check_log = CHECK_PYSPARK(check_script)

  // Generar gráficos
  PLOT(summaries.collect(), regex_out.collect())
}