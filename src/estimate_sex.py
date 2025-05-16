import os
import pandas as pd
from functions import parse_arguments

args         = parse_arguments()
sample       = args.sample
mosdepth_dir = args.input_dir
output_dir   = args.output_dir

x_female_high = 0.8
y_female_low  = 0.2
x_male_low    = 0.6
y_male_high   = 0.2

summary_file = os.path.join(mosdepth_dir,sample, f"{sample}.mosdepth.summary.txt")
report_file  = os.path.join(output_dir, f"{sample}_sex_estimate.txt")

x_chr = "chrX"
y_chr = "chrY"

df = pd.read_csv(summary_file, sep = '\t', index_col = 'chrom')
x_coverage = df.loc[x_chr, 'mean']
y_coverage = df.loc[y_chr, 'mean']

# Here I assume that autosome coverage can be approx. by the avg. coverage
# of all autosomal chromosomes (excluding X and Y).
autosome_coverage = df[~df.index.isin([x_chr, y_chr])]['mean'].mean()
print(f"Mean x cov.: {x_coverage}")
print(f"Mean y cov.: {y_coverage}")
print(f"Mean autosome cove.: {autosome_coverage}")

if autosome_coverage == 0:
    print("Error: Could not determine autosome coverage.")
    # return
x_ratio = x_coverage / autosome_coverage if autosome_coverage > 0 else 0
y_ratio = y_coverage / autosome_coverage if autosome_coverage > 0 else 0


# Heuristic for sex determination based on coverage ratios with externalized thresholds
if x_ratio > x_female_high and y_ratio < y_female_low:
    predicted_sex = "Female (XX)"
    confidence = "High"
elif x_ratio < x_male_low and y_ratio > y_male_high:
    predicted_sex = "Male (XY)"
    confidence = "High"
elif x_ratio > x_male_low and y_ratio > y_female_low:
    predicted_sex = "Likely Female or potential aneuploidy (e.g., XXY)"
    confidence = "Medium"
elif x_ratio < x_female_high and y_ratio < y_male_high:
    predicted_sex = "Likely Male or potential aneuploidy (e.g., X0)"
    confidence = "Medium"
else:
    predicted_sex = "Indeterminate"
    confidence = "Low"

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

with open(report_file, 'w') as outfile:
    outfile.write(f"Sample: {sample}\n")
    outfile.write(f"{x_chr} Chromosome Coverage: {x_coverage:.2f}\n")
    outfile.write(f"{y_chr} Chromosome Coverage: {y_coverage:.2f}\n")
    outfile.write(f"Average Autosome Coverage: {autosome_coverage:.2f}\n")
    outfile.write(f"{x_chr}/Autosome Coverage Ratio: {x_ratio:.2f}\n")
    outfile.write(f"{y_chr}/Autosome Coverage Ratio: {y_ratio:.2f}\n")
    outfile.write(f"Predicted Sex: {predicted_sex}\n")
    outfile.write(f"Confidence: {confidence}\n")

print(f"Sex estimation for {sample} complete.")
print(f"Predicted sex: {predicted_sex}.")
print(f"Results saved to {report_file}")
