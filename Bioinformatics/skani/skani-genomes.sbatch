#!/usr/bin/env bash
#SBATCH --job-name=skani-genomes
#SBATCH --time 1-0                         
#SBATCH -p sched_mit_chisholm
#SBATCH -c 5  # CPUs (threads)      
#SBATCH -N 1
#SBATCH --mem 5G
#SBATCH -o logs/skani_genome.%j.out
#SBATCH -e logs/skani_genome.%j.err

## DESCRIPTION ##
# Runs skani to obtain ANI (Average Nucleotide Identify) of 2 genomes #
# Set up: 
    # Create conda env with skani installed 
        # conda create -n skani -c bioconda skani 

source activate skani

# obtain comparison name and genome paths
comparison_name=genome1_vs_genome2
genome1_path=path/to/genome1/genome1.fasta
genome2_path=path/to/genome1/genome2.fasta

echo Comparing: $comparison_name
echo Path1: $genome1_path
echo Path2: $genome2_path
date

# make output dir
outdir="output"
mkdir -p ${outdir}

# run skani on genomes 
skani dist \
    -t ${SLURM_CPUS_PER_TASK} \
    ${genome1_path} \
    ${genome2_path} \
    > ${outdir}/skani-genomes-out.tsv

echo skani genomes complete!
date