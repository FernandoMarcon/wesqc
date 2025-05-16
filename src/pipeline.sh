#!/bin/bash

# INPUT
SAMPLE="NA06994"
CRAM="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
REF="GRCh38_full_analysis_set_plus_decoy_hla.fa"
BED="hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"

THREADS=10
LOGDIR="logs/${SAMPLE}"
mkdir -p ${LOGDIR}
mkdir -p results/{mosdepth,coverage,sex_inference,contamination}

### Run scripts
# Coverage analysis
#MOSDEPTH_DIR="results/mosdepth/${SAMPLE}"
#mkdir -p ${MOSDEPTH_DIR}
#mosdepth --threads ${THREADS}          \
#	--by data/bed/${BED}           \
#	--fasta data/ref/${REF}        \
#	${MOSDEPTH_DIR}/${SAMPLE}      \
#	data/cram/${CRAM} \
#	2> ${LOGDIR}/mosdepth.log
#
#python src/calc_coverage.py --sample ${SAMPLE} \
#	--input-dir results/mosdepth \
#	--output-dir results/coverage \
#	2> ${LOGDIR}/calc_coverage.log
#
## Sex inference
#python src/estimate_sex.py --sample ${SAMPLE} \
#	--input-dir results/mosdepth \
#	--output-dir results/sex_inference \
#	2> ${LOGDIR}/estimate_sex.log


# Contamination estimation
bash src/contamination.sh ${SAMPLE} \
	data/cram/${CRAM} \
	results/contamination/ \
	data/ref/${REF} \
	data/bed/${BED} \
	${THREADS} \
	2> ${LOGDIR}/contamination.log

echo "Pipeline completed"
