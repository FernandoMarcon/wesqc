import pandas as pd
from functions import parse_arguments

args         = parse_arguments()
sample       = args.sample
mosdepth_dir = args.input_dir
output_dir   = args.output_dir

regions_file = f"{mosdepth_dir}/{sample}/{sample}.regions.bed.gz"
output_dir   = f"results/coverage"

df = pd.read_csv(regions_file, sep="\t", header=None, compression="gzip")

coverage = df.iloc[:, -1].astype(float) # last column -> mean depth
start    = df.iloc[:, 1].astype(int)
end      = df.iloc[:, 2].astype(int)
lengths  = end - start

# Total exonic bases
total_bases = lengths.sum()

# Mean coverage (wiehghted by region length)
mean_depth = (coverage * lengths).sum() / total_bases

# % of bases with coverage >=10 and >= 30x
bases10 = lengths[coverage >= 10].sum()
bases30 = lengths[coverage >= 30].sum()
pct10   = bases10 / total_bases * 100
pct30   = bases30 / total_bases * 100

# Save
with open(f"{output_dir}/{sample}.coverage_stats.txt","w") as f:
    f.write(f"Mean coverage (exonic): {mean_depth:.2f}\n")
    f.write(f"% bases >= 10x: {pct10:.2f}%\n")
    f.write(f"% bases >= 30x: {pct30:.2f}%\n")
