#!/usr/bin/env bash
#SBATCH --job-name=skani-reads
#SBATCH --time 1-0                         
#SBATCH -p sched_mit_chisholm
#SBATCH -c 5  # CPUs (threads)           
#SBATCH -N 1
#SBATCH --mem 5G
#SBATCH -o logs/skani_reads.%j.out
#SBATCH -e logs/skani_reads.%j.err

## DESCRIPTION ##
# Runs skani to obtain ANI (Average Nucleotide Identify) of 2 read sets #
# Set up: 
    # Create conda env with skani installed 
        # conda create -n skani -c bioconda skani 

source activate skani

# obtain comparison name and genome paths
comparison_name=readset1_vs_readset2
read1_path=path/to/readset_1/readset_1.fasta
read2_path=path/to/readset_2/readset_2.fasta

echo Comparing: $comparison_name
echo Path1: $read1_path
echo Path2: $read2_path
date

# make output dir
outdir="output"
mkdir -p ${outdir}

# note: query each individal record in a multi-fasta (--qi for query, --ri for reference)
skani dist \
    -t ${SLURM_CPUS_PER_TASK} \
    --qi -q ${read1_path} \
    --ri -r ${read2_path} \
    > ${outdir}/skani-reads-out.tsv

echo skani reads complete!
date