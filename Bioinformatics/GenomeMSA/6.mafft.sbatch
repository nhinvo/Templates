#!/usr/bin/env bash
#SBATCH --job-name=mafft
#SBATCH --time 1-0                   
#SBATCH -p sched_mit_chisholm             
#SBATCH -c 3                          
#SBATCH -N 1
#SBATCH --mem 10G
#SBATCH --array=START-END%TOTAL_NUM
#SBATCH -o logs/mafft.%j.out
#SBATCH -e logs/mafft.%j.err

# Purpose: to align genomes
# Set up: 
    # Install mafft: conda create -n mafft -c bioconda mafft

source activate mafft

inputs="output/msa_inputs"
input=$(realpath ${inputs}/* | sed -n ${SLURM_ARRAY_TASK_ID}p)  # obtain path to genome (based on slurm task)

name=`basename "$input" .fna`  # name of msa

outdir="output/msa_out"
mkdir -p ${outdir}

echo $name
mafft "$input" > "${outdir}/${name}.aln"