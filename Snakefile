configfile: "config.yaml"
import os

cram_dir = config["cram_dir"]
results_dir = config["results_dir"]
logs_dir = config["logs_dir"]
ref_dir = config["ref_dir"]
bed_dir = config["bed_dir"]
threads = config["threads"]
ref = config["ref"]
bed = config["bed"]

# list files in data/cram that end with .cram
suffix = config["suffix"]
crams = [f.replace(".cram", "") for f in os.listdir(cram_dir) if f.endswith(".cram")]
samples = [f.replace(suffix, "") for f in crams]
print(samples)
print(crams)

rule all:
    input:
        mosdepth = expand(f"{results_dir}/mosdepth/{{sample}}/{{sample}}.regions.bed.gz", sample=samples),
        coverage = expand(f"{results_dir}/coverage/{{sample}}.coverage_stats.txt", sample=samples),
        sex = expand(f"{results_dir}/sex_inference/{{sample}}_sex_estimate.txt", sample=samples),
        contamination = expand(f"{results_dir}/contamination/{{sample}}/{{sample}}_contamination.txt", sample=samples)

rule mosdepth:
    input:
        cram = f"{cram_dir}/{{sample}}{suffix}.cram",
        ref = os.path.join(ref_dir, ref),
        bed = os.path.join(bed_dir, bed)
    output:
        regions = f"{results_dir}/mosdepth/{{sample}}/{{sample}}.regions.bed.gz",
        global_dist = f"{results_dir}/mosdepth/{{sample}}/{{sample}}.mosdepth.global.dist.txt",
        region_dist = f"{results_dir}/mosdepth/{{sample}}/{{sample}}.mosdepth.region.dist.txt"
    log:
        f"{logs_dir}/{{sample}}/mosdepth.log"
    threads: threads
    shell:
        """
        bash src/run_mosdepth.sh \
            --sample {wildcards.sample} \
            --cram {input.cram} \
            --outdir {results_dir}/ \
            --ref {input.ref} \
            --bed {input.bed} \
            --threads {threads} \
            2> {log}
        """

rule calc_coverage:
    input:
        mosdepth = rules.mosdepth.output.regions
    output:
        coverage = f"{results_dir}/coverage/{{sample}}.coverage_stats.txt"
    log:
        f"{logs_dir}/{{sample}}/calc_coverage.log"
    shell:
        """
        python src/calc_coverage.py \
            --sample {wildcards.sample} \
            --input-dir {results_dir}/mosdepth \
            --output-dir {results_dir}/coverage \
            2> {log}
        """

rule estimate_sex:
    input:
        mosdepth = rules.mosdepth.output.regions
    output:
        sex = f"{results_dir}/sex_inference/{{sample}}_sex_estimate.txt"
    log:
        f"{logs_dir}/{{sample}}/estimate_sex.log"
    shell:
        """
        python src/estimate_sex.py \
            --sample {wildcards.sample} \
            --input-dir {results_dir}/mosdepth \
            --output-dir {results_dir}/sex_inference \
            2> {log}
        """

rule contamination:
    input:
        cram = f"{cram_dir}/{{sample}}{suffix}.cram",
        ref = os.path.join(ref_dir, ref),
        bed = os.path.join(bed_dir, bed)
    output:
        contamination = f"{results_dir}/contamination/{{sample}}/{{sample}}_contamination.txt"
    log:
        f"{logs_dir}/{{sample}}/contamination.log"
    threads: threads
    shell:
        """
        bash src/contamination.sh \
            --sample {wildcards.sample} \
            --cram {input.cram} \
            --outdir {results_dir}/contamination \
            --ref {input.ref} \
            --bed {input.bed} \
            --threads {threads} \
            2> {log}
        """ 