import os
import pandas as pd
import yaml
from functions import parse_arguments

# Parse command line arguments
args         = parse_arguments()
sample       = args.sample
mosdepth_dir = args.input_dir
output_dir   = args.output_dir

# Load config file
with open('config.yaml', 'r') as f:
    config = yaml.safe_load(f)

# Get thresholds from config
thresholds = config['sex_inference']
x_female_threshold = thresholds['x_female_threshold']
x_male_threshold = thresholds['x_male_threshold']
y_threshold = thresholds['y_threshold']

summary_file = os.path.join(mosdepth_dir,sample, f"{sample}.mosdepth.summary.txt")
report_file  = os.path.join(output_dir, f"{sample}_sex_estimate.txt")

x_chr = "chrX"
y_chr = "chrY"

df = pd.read_csv(summary_file, sep = '\t', index_col = 'chrom')
x_coverage = df.loc[x_chr, 'mean']
y_coverage = df.loc[y_chr, 'mean']

# Calculate autosome coverage (excluding X and Y)
autosome_coverage = df[~df.index.isin([x_chr, y_chr])]['mean'].mean()
print(f"Mean X coverage: {x_coverage}")
print(f"Mean Y coverage: {y_coverage}")
print(f"Mean autosome coverage: {autosome_coverage}")

if autosome_coverage == 0:
    print("Error: Could not determine autosome coverage.")
    exit(1)

# Calculate X and Y coverage ratios
x_ratio = x_coverage / autosome_coverage
y_ratio = y_coverage / autosome_coverage

# Simplified sex determination based on coverage ratios
if x_ratio >= x_female_threshold and y_ratio < y_threshold:
    predicted_sex = "Female"
elif x_ratio <= x_male_threshold and y_ratio >= y_threshold:
    predicted_sex = "Male"
else:
    predicted_sex = "Indeterminate"

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Write results
with open(report_file, 'w') as outfile:
    outfile.write(f"Sample: {sample}\n")
    outfile.write(f"X Chromosome Coverage: {x_coverage:.2f}\n")
    outfile.write(f"Y Chromosome Coverage: {y_coverage:.2f}\n")
    outfile.write(f"Average Autosome Coverage: {autosome_coverage:.2f}\n")
    outfile.write(f"X/Autosome Ratio: {x_ratio:.2f}\n")
    outfile.write(f"Y/Autosome Ratio: {y_ratio:.2f}\n")
    outfile.write(f"Predicted Sex: {predicted_sex}\n")
    outfile.write(f"\nThresholds used:\n")
    outfile.write(f"X Female Threshold: {x_female_threshold}\n")
    outfile.write(f"X Male Threshold: {x_male_threshold}\n")
    outfile.write(f"Y Threshold: {y_threshold}\n")

print(f"Sex estimation for {sample} complete.")
print(f"Predicted sex: {predicted_sex}")
print(f"Results saved to {report_file}")
