#!/usr/bin/env bash
#SBATCH --job-name=kaiju_refseq
#SBATCH --time 1-0  
#SBATCH -p PARTITION_NAME  
#SBATCH -c 10  
#SBATCH -N 1
#SBATCH --mem 50G
#SBATCH --array=START-END%TOTAL_NUM
#SBATCH -o logs/kaiju.%a.%j.out
#SBATCH -e logs/kaiju.%a.%j.err

## DESCRIPTION ##
# Runs Kaiju on a list of samples in samples.tsv #
# Set up: 
    # Install kaiju refseq database following instruction on their documentation #
    # samples.tsv: 
        # First column = unqiue sample name #
        # Second column = path to forward read #
        # Third column = path to reverse read #
    # Edit SBATCH --array to number of samples
    # Create conda env with Kaiju installed 
        # conda create -n kaiju -c bioconda kaiju 

# Paths to Kaiju Refseq Database
db_index=kaiju_refseq/kaiju_db_refseq_nr.fmi
nodes_dmp=kaiju_refseq/nodes.dmp
names_dmp=kaiju_refseq/names.dmp

# Path to read file and unique sample name
sample=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f1 | tr -d '\r')
forward_read=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f2 | tr -d '\r')
reverse_read=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f3 | tr -d '\r')

# Create output directory 
outdir="output/refseq_kaiju_out"
mkdir -p ${outdir}

# Activate conda env 
source activate kaiju

echo Starting kaiju on ${sample}...
date

# Base Kaiju 
kaiju \
    -z ${SLURM_CPUS_PER_TASK} -v \
    -t ${nodes_dmp} -f ${db_index} \
    -i ${forward_read} ${reverse_read} 
    -o "${outdir}/${sample}_kaiju.out"

# Kaiju Name (add full taxonomic classification to read)
kaiju-addTaxonNames \
    -t ${nodes_dmp} -n ${names_dmp} -p \
    -i "${outdir}/${sample}_kaiju.out" \
    -o "${outdir}/${sample}_kaiju_names.out"

# Kaiju Summary (genus level)
kaiju2table \
    -t ${nodes_dmp} -n ${names_dmp} \
    -r genus -m 0.0 \
    -o "${outdir}/${sample}_genus_kaiju_summary.tsv" \
    "${outdir}/${sample}_kaiju.out"

echo Completed sample $sample!
date

conda deactivate 