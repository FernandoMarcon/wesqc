#!/bin/bash

# =======================================================
# Coverage Analysis
# Script to calculate coverage using mosdepth
# =======================================================


set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure


# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Required Arguments:"
    echo "  -s, --sample    Sample identifier"
    echo "  -c, --cram     Path to input CRAM file"
    echo "  -o, --outdir   Base output directory"
    echo "  -r, --ref      Path to reference genome FASTA"
    echo "  -b, --bed      Path to BED file with target regions"
    echo "  -t, --threads  Number of threads to use"
    echo
    echo "Example:"
	echo "  $0 -s NA06994 -c data/cram/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram -r data/ref/GRCh38_full_analysis_set_plus_decoy_hla.fa -b data/bed/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed  -t 10 -o results/mosdepth/NA06994"
    echo
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--sample)
            SAMPLE_ID="$2"
            shift 2
            ;;
        -c|--cram)
            CRAM_FILE="$2"
            shift 2
            ;;
        -o|--outdir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -r|--ref)
            REFERENCE="$2"
            shift 2
            ;;
        -b|--bed)
            BED_FILE="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Invalid argument: $1"
            usage
            ;;
    esac
done	

# Validate required arguments
if [ -z "${SAMPLE_ID}" ] || [ -z "${CRAM_FILE}" ] || [ -z "${OUTPUT_DIR}" ] || [ -z "${REFERENCE}" ] || [ -z "${BED_FILE}" ] || [ -z "${THREADS}" ]; then
    echo "Error: Missing required arguments"
    usage
fi

# Create output directories
mkdir -p "${OUTPUT_DIR}/mosdepth/${SAMPLE_ID}"

# Run mosdepth
mosdepth --threads ${THREADS} \
	--by ${BED_FILE} \
	--fasta ${REFERENCE} \
	${OUTPUT_DIR}/mosdepth/${SAMPLE_ID}/${SAMPLE_ID} \
	${CRAM_FILE}

# Check if the output files exist print ok else print error
if [[ -f ${OUTPUT_DIR}/mosdepth/${SAMPLE_ID}/${SAMPLE_ID}.regions.bed.gz ]]; then
    echo "Analysis completed successfully. Results are in: $OUTPUT_DIR/mosdepth/${SAMPLE_ID}"
else
    echo "mosdepth regions bed file does not exist"
    exit 1
fi    