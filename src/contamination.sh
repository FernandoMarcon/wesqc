#!/bin/bash

# =======================================================
# Contamination Analysis
# Script to estimate DNA contamination using VerifyBamID
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
    echo "  $0 -s NA12878 -c input.cram -o results/contamination -r ref.fa -b targets.bed -t 4"
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
            BASE_OUTPUT_DIR="$2"
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
            echo "Error: Unknown parameter $1"
            usage
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "${SAMPLE_ID:-}" ] || [ -z "${CRAM_FILE:-}" ] || [ -z "${BASE_OUTPUT_DIR:-}" ] || \
   [ -z "${REFERENCE:-}" ] || [ -z "${BED_FILE:-}" ] || [ -z "${THREADS:-}" ]; then
    echo "Error: Missing required arguments"
    usage
fi

# Validate inputs
for file in "$CRAM_FILE" "$REFERENCE" "$BED_FILE"; do
    if [ ! -f "$file" ]; then
        echo "Error: File does not exist: $file"
        exit 1
    fi
done

if ! [[ "$THREADS" =~ ^[0-9]+$ ]]; then
    echo "Error: Threads must be a positive integer"
    exit 1
fi

# Create sample-specific output directory
SAMPLE_OUTPUT_DIR="${BASE_OUTPUT_DIR}/${SAMPLE_ID}"
if ! mkdir -p "$SAMPLE_OUTPUT_DIR"; then
    echo "Error: Failed to create output directory: $SAMPLE_OUTPUT_DIR"
    exit 1
fi

SVD_DIR="$(pwd)/resource"
if [ ! -d "$SVD_DIR" ]; then
    echo "Error: VerifyBamID2 resource directory not found: $SVD_DIR"
    exit 1
fi

SVD_PREFIX="${SVD_DIR}/1000g.phase3.100k.b38.vcf.gz.dat"
if [ ! -f "${SVD_PREFIX}.mu" ]; then
    echo "Error: VerifyBamID2 resource files not found in: $SVD_DIR"
    exit 1
fi

echo "Starting contamination analysis for sample: $SAMPLE_ID"
echo "Output directory: $SAMPLE_OUTPUT_DIR"

# Run VerifyBamID2
if ! verifybamid2 \
    --SVDPrefix "$SVD_PREFIX" \
    --Reference "$REFERENCE" \
    --BamFile "$CRAM_FILE" \
    --BedPath "$BED_FILE" \
    --NumThread "$THREADS" \
    --Output "${SAMPLE_OUTPUT_DIR}/${SAMPLE_ID}"; then
    echo "Error: VerifyBamID2 analysis failed"
    exit 1
fi

# Create a simplified output file with just the contamination estimate
CONTAMINATION_FILE="${SAMPLE_OUTPUT_DIR}/${SAMPLE_ID}_contamination.txt"
if [ -f "${SAMPLE_OUTPUT_DIR}/${SAMPLE_ID}.selfSM" ]; then
    awk 'NR==2 {printf "Contamination estimate: %.4f\n", $7}' "${SAMPLE_OUTPUT_DIR}/${SAMPLE_ID}.selfSM" > "$CONTAMINATION_FILE"
    echo "Analysis completed successfully. Results are in: $SAMPLE_OUTPUT_DIR"
    echo "Contamination summary written to: $CONTAMINATION_FILE"
else
    echo "Error: VerifyBamID2 output file not found"
    exit 1
fi