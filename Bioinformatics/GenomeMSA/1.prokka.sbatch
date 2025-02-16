#!/usr/bin/env bash
#SBATCH --job-name=annot-prokka
#SBATCH --time 1-0          
#SBATCH -p sched_mit_chisholm               
#SBATCH -c 1                             
#SBATCH -N 1
#SBATCH --mem 1G
#SBATCH --array=START-END%TOTAL_NUM
#SBATCH -o logs/annot.%a.%j.out
#SBATCH -e logs/annot.%a.%j.err

## DESCRIPTION ##
# Runs prokka annotation on a directory of genomes specified #
# Set up: 
    # Edit SBATCH --array to number of samples
    # Create conda env with Prokka installed 
        # conda create -n prokka -c bioconda prokka
    # Create logs/ directory 

source activate prokka

# Path to directory with genomes for annotation
genome_dir="path/to/genome_dir"

# path to genome for annotation (sequential based on slurm task)
genome_path=$(realpath ${genome_dir}/* | sed -n ${SLURM_ARRAY_TASK_ID}p)

# name of genome without the .fasta extension 
genome_name=`basename $assembly .fasta`  # name without fasta extention 

# output directory
outdir="output/annotated-genomes"

echo Running prokka on: ${genome_name}...
date

prokka \
    --outdir ${outdir}/${genome_name}/ \
    --prefix ${genome_name} \
    ${genome_path}

echo complete!
date