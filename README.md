# Técnicas de programación avanzada
## Doctorado en informática aplicada a la salud y medioambiente

El objetivo de este trabajo es aplicar los conceptos aprendidos durante la Segunda Unidad.

El trabajo consta de tres partes:

1. Pipeline en Nextflow
2. repositorio en Github
3. Informe en jupyter notebook.

### Project Organization

```
.
├── bin                                         : Carpeta bin
├── data                                        : Contiene los archivos descargados con el proceso DOWNLOAD
├── results                                     : Carpeta de resultados
├── scripts                                     : Carpeta que contiene los scripts
├── work                                        : carpeta de trabajo
├── informe.ipynb                               : Informe del trabajo
├── nextflow.config                             : Archivo de configuración
├── main.nf                                     : Nextflow main
├── parser.py                                   : Script de ejemplo
└── README.md                                   : Descripción general del proyecto
```


---

## 🚀 Requisitos

- **Nextflow** ≥ 24.06.06  
- **Java** 11 o 17 (OpenJDK u Oracle)  
- **Python** 3.12.5  
- **PySpark** 4.0.0  
- **Pandas** 2.0.x  
- **Matplotlib** 3.7.x  
- **Bash** (macOS o GNU)  

> Para la descarga de FASTA necesita acceso SSH al clúster remoto.  

---

## 🔧 Instalación

1. Clona el repositorio y entra al directorio:
   ```bash
   git clone https://github.com/fespinozav/TAP.git
   cd TAP

2.	Prepara un entorno Python (opcional, recomendado):
python3 -m venv .venv
source .venv/bin/activate
pip install pyspark pandas matplotlib

3.	Verifica versiones:
nextflow -v
java -version
pip show pyspark pandas matplotlib

## ⚙️ Configuración

Los parámetros principales están en main.nf:
	•	params.data_dir (por defecto data)
	•	params.kmer (dinucleótido a contar, por defecto GC)
	•	params.results (carpeta de salida, por defecto results)

## 📥 Ejecución

nextflow run main.nf -profile local


