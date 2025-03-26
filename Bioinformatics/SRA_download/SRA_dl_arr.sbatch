#!/usr/bin/env bash
#SBATCH --job-name sratools-prefetch
#SBATCH --time 12:00:00  
#SBATCH --partition PARTITION_NAME  # name of compute partition 
#SBATCH --cpus-per-task 1  
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH --mem 1G
#SBATCH --array=START-END%VAL
#SBATCH -o logs/%j_%a.out
#SBATCH -e logs/%j_%a.err

#################
## DESCRIPTION ##
# Runs prefect then fasterq-dump on a list of SRR accession numbers in parallel #
# Set up: 
    # Create conda env with sra-tools installed 
        # conda create -n sratools -c bioconda sra-tools
    # Edit path to output for files: $OUTPUT_DIR
    # Edit path to input list of accessions $ACCESSION_FILE
        # example provided: PRJNA358725_SRA_ACC_List.csv
    # Create directory logs/ where you're running this script
    # edit partition name and sbatch array specifications
#################

date

echo "SLURM Job ID: ${SLURM_JOB_ID}"
echo "Array index number: ${SLURM_ARRAY_TASK_ID} (out of: ${SLURM_ARRAY_TASK_MAX})"
echo "Array Job ID: ${SLURM_ARRAY_JOB_ID}"
echo "CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"

# activate any conda environment neccesary 
conda activate sratools

## Obtain SRR ID from a list
ACCESSION_FILE="path/to/list.txt"
SRR_ID=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ACCESSION_FILE} | cut -f1 | tr -d '\r')

# path to output dir for sample
OUTPUT_DIR="path/to/output/dir/for/SRA"

# Download file 
echo Downloading ${SRR_ID}...

prefetch \
    ${SRR_ID} \
    --output-directory ${OUTPUT_DIR}

fasterq-dump \
    ${OUTPUT_DIR}/${SRR_ID}/ \
    --force --temp ${OUTPUT_DIR} \
    --threads ${SLURM_CPUS_PER_TASK} \
    --outdir ${OUTPUT_DIR}

echo done!
date