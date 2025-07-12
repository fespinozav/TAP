#!/usr/bin/env bash
# Remote user and server
REMOTE_USER="fespinoza"
REMOTE_HOST="faraday.utem.cl"
REMOTE_DIR="/home/amoya/Data_forTap/selected_Genomes"
dest=$1

# Ensure destination exists
mkdir -p "$dest"

# Fetch the first 5 FASTA filenames from the Faraday server, then copy them locally
ssh "${REMOTE_USER}@${REMOTE_HOST}" "ls ${REMOTE_DIR}/*.fna | head -n 5" | \
while read -r file; do
  scp "${REMOTE_USER}@${REMOTE_HOST}:${file}" "$dest/"
done