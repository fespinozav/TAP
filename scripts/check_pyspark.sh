#!/usr/bin/env bash
python3 - <<'EOF'
try:
  import pyspark
except ImportError:
  exit 1
EOF
if [ $? -eq 1 ]; then
  echo "Instalando PySpark..."
  pip3 install --user pyspark
else
  echo "PySpark ya está instalado."
fi