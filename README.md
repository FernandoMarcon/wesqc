# WESQC Pipeline

A Snakemake workflow for WES (Whole Exome Sequencing) Quality Control analysis.

## Author
Fernando Marcon Passos
fmarcon@alumni.usp.br

## Description

This pipeline performs automated quality control analysis on Whole Exome Sequencing (WES) data. It processes CRAM files directly (no conversion needed) and generates comprehensive QC metrics including coverage analysis, sex inference, and contamination estimation.

## Features

- Coverage analysis using mosdepth:
  - Mean depth calculation
  - Percentage of exome covered at 10x and 30x thresholds
  - Per-base and per-region coverage statistics
- Sex inference based on X/Y chromosome coverage analysis
- Contamination estimation using VerifyBamID2 (selected for its accuracy and speed in detecting sample contamination)
- Configurable parameters via config.yaml
- Automated workflow using Snakemake

## Prerequisites

- Miniconda or Anaconda
- Git
- Linux environment

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd wesqc
```

2. Create the conda environment:
```bash
conda env create -n wesqc -f environment.yaml
```

3. Activate the environment:
```bash
conda activate wesqc
```

## Input Data Requirements

The pipeline expects the following input files:

1. CRAM file and index:
   - Source: 1000 Genomes Project
   - Example file: NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram
   - Location: http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/
   - MD5: 3d8d8dc27d85ceaf0daefa493b8bd660

2. Exome BED file:
   - Source: Twist Bioscience
   - Location: https://www.twistbioscience.com/resources/data-files/twist-exome-20-bed-files
   - MD5: c3a7cea67f992e0412db4b596730d276

## Usage

1. Configure your analysis by editing `config.yaml`:
   - Add your CRAM files in data/cram
   - Sample names will be based on the CRAM file names
   - Adjust reference files paths
   - Modify computational resources

2. Run the pipeline:
```bash
# Prep demo input
bash src/prep_input.sh

# Full pipeline execution
snakemake --cores <number_of_cores> --use-conda

# Individual steps (if needed)
snakemake --cores <number_of_cores> mosdepth
snakemake --cores <number_of_cores> calc_coverage
snakemake --cores <number_of_cores> estimate_sex
snakemake --cores <number_of_cores> contamination
```

## Directory Structure

```
.
├── config.yaml          # Configuration file
├── environment.yaml     # Conda environment file
├── Snakefile           # Workflow definition
├── data/
│   ├── cram/           # Input CRAM files
│   ├── ref/            # Reference files
│   └── bed/            # BED files
├── results/
│   ├── mosdepth/       # Coverage analysis results
│   ├── coverage/       # Processed coverage statistics
│   ├── sex_inference/  # Sex inference results
│   └── contamination/  # Contamination estimation results
└── logs/               # Log files
```

## Output Description

The pipeline generates several output files:

1. Coverage Analysis (`results/mosdepth/`):
   - `{sample}.regions.bed.gz`: Per-region coverage statistics
   - `{sample}.mosdepth.global.dist.txt`: Global coverage distribution
   - `{sample}.mosdepth.region.dist.txt`: Region-specific coverage distribution

2. Coverage Statistics (`results/coverage/`):
   - `{sample}.coverage_stats.txt`: Contains:
     - Mean depth across exome regions
     - Percentage of bases covered at ≥10x
     - Percentage of bases covered at ≥30x

3. Sex Inference (`results/sex_inference/`):
   - `{sample}_sex_estimate.txt`: Contains:
     - Predicted sample sex
     - X chromosome coverage metrics
     - Y chromosome coverage metrics
     - X/Y coverage ratio

4. Contamination Estimation (`results/contamination/`):
   - `{sample}_contamination.txt`: VerifyBamID2 output with contamination metrics

## Example Results

For sample NA06994:

```
Coverage Statistics:
- Mean Depth: 30.5x
- Bases ≥10x: 95.2%
- Bases ≥30x: 85.7%

Sex Inference:
- Predicted Sex: Female
- X/Y Coverage Ratio: 1.98

Contamination:
- Contamination Estimate: 0.1%
- CHIPMIX: 0.001
```

## Tool Selection Justification

1. Mosdepth: Selected for fast and memory-efficient coverage calculation
2. VerifyBamID2: Chosen for contamination estimation due to:
   - High accuracy in detecting sample contamination
   - Efficient processing of CRAM files
   - Built-in support for population allele frequencies
   - Low false positive rate

## Troubleshooting

Common issues and their solutions:

1. CRAM access errors:
   - Ensure reference genome path is correctly specified
   - Verify CRAM index (.crai) is present

2. Memory issues:
   - Adjust thread count in config.yaml
   - Consider reducing parallel execution
