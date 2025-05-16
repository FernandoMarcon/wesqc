#!/bin/bash

# =======================================================
# Contamination Analysis
# Script to estimate DNA contamination using VerifyBamID
# =======================================================

SAMPLE=$1
CRAM=$2
OUTPUT_DIR=$3
REF=$4
BED=$5
THREADS=$6

OUTPUT_DIR=${OUTPUT_DIR}/${SAMPLE}
mkdir -p $OUTPUT_DIR

SVD_DIR="${HOME}/miniconda3/envs/wesqc/share/verifybamid2-2.0.1-12"
verifybamid2 \
  --SVDPrefix "${SVD_DIR}/resource/1000g.phase3.100k.b38.vcf.gz.dat" \
  --Reference $REF \
  --BamFile $CRAM \
  --BedPath $BED \
  --NumThread $THREADS \
  --Output $OUTPUT_DIR/${SAMPLE}


# Check if VerifyBamID ran successfully
if [ $? -eq 0 ]; then
  echo "VerifyBamID analysis completed successfully. Results are in ${OUTPUT_DIR}/${SAMPLE}/"
else
  echo "Error: VerifyBamID analysis failed."
  exit 1
fi
