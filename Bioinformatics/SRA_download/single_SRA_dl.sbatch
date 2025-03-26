#!/usr/bin/env bash
#SBATCH --job-name=dl_SRA
#SBATCH --time 2-0                        
#SBATCH --partition PARTITION_NAME              
#SBATCH --cpus-per-task 1            
#SBATCH -N 1                    
#SBATCH -o sratools-%j.out
#SBATCH -e sratools-%j.err

#################
## DESCRIPTION ##
# Runs prefect and fasterq-dump to download a read file from SRA #
# Set up: 
    # Create conda env with sra-tools installed 
        # conda create -n sratools -c bioconda sra-tools
    # Edit paths to: $OUTPUT_DIR
    # Edit $SRR ID 
#################

source activate sratools

OUTPUT_DIR="path/to/output/dir"
SRR=example_SRR5788281

prefetch \
    ${SRR} \
    --output-directory ${OUTPUT_DIR}


fasterq-dump \
    ${OUTPUT_DIR}/${SRR} \
    --outdir ${OUTPUT_DIR}