#!/bin/bash

# Download and validate input files integrity
# This script checks the MD5 hashes of input files against expected values

set -e
set -u
set -o pipefail

CRAM_URL="http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment"
CRAM_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
BED_URL="https://www.twistbioscience.com/sites/default/files/resources/2022-12/"
BED_FILE="hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"

# Download files
mkdir -p data/{cram,bed}
#wget -P data/cram/ $CRAM_URL/$CRAM_FILE 
wget -P data/cram/ "$CRAM_URL/$CRAM_FILE.crai"
wget -P data/bed/ $BED_URL/$BED_FILE


# Expected MD5 hashes
EXPECTED_CRAM_MD5="3d8d8dc27d85ceaf0daefa493b8bd660"
EXPECTED_CRAI_MD5="15a6576f46f51c37299fc004ed47fcd9"
EXPECTED_BED_MD5="c3a7cea67f992e0412db4b596730d276"

# Function to check MD5
check_md5() {
    local file=$1
    local expected=$2
    local computed

    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi

    computed=$(md5sum "$file" | cut -d' ' -f1)
    if [ "$computed" != "$expected" ]; then
        echo "Error: MD5 mismatch for $file"
        echo "Expected: $expected"
        echo "Computed: $computed"
        return 1
    fi
    echo "MD5 check passed for $file"
    return 0
}


# Check MD5 hashes
check_md5 "data/cram/$CRAM_FILE" "$EXPECTED_CRAM_MD5"
check_md5 "data/cram/$CRAM_FILE.crai" "$EXPECTED_CRAI_MD5"
check_md5 "data/bed/$BED_FILE" "$EXPECTED_BED_MD5"

echo "All input files validated successfully!" 