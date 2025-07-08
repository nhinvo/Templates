#!/usr/bin/env bash
#SBATCH --job-name MAG-Assembly

#SBATCH --time 2-0
#SBATCH --partition PARTITION_NAME 
#SBATCH --cpus-per-task 64
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH --mem 800000
#SBATCH --array=1-3%3

#SBATCH -o logs/SpadesAssembly/%a-%j.out
#SBATCH -e logs/SpadesAssembly/%a-%j.err


#######################################################
## DESCRIPTION ##
# Runs Spades genome assembly #
# Set up: 
    # 1. Edit SBATCH specifications above 
    # 2. Install conda environment: 
        # spades-4.2.0: with spades v.4.2.0
    # 3. Create logs/SpadesAssembly/ directory where this script will be submitted 
    # 4. Create samples.tsv file
    # 5. Edit output ${OUTPUT_DIR}
    # 6. Submit script using `sbatch 01.SpadesAssembly.sbatch`

# Note: 
    # if Spades fail due to time limit, run spades with --continue flag 


#######################################################
## SOME STATS ##
echo "$(date): SLURM Job ID: ${SLURM_JOB_ID}"
echo "$(date): Array index number: ${SLURM_ARRAY_TASK_ID} (out of: ${SLURM_ARRAY_TASK_MAX})"
echo "$(date): Array Job ID: ${SLURM_ARRAY_JOB_ID}"
echo "$(date): CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"


########################################################################################
## SET UP ##
# INPUT
SAMPLE_NAME=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f1 | tr -d '\r')
FWD_READS=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f2 | tr -d '\r')
REV_READS=$(sed "${SLURM_ARRAY_TASK_ID}q;d" samples.tsv | cut -f3 | tr -d '\r')
echo Processing: ${SAMPLE_NAME}

# OUTPUT 
OUTPUT_DIR=path/to/output_dir
mkdir -p ${OUTPUT_DIR}


########################################################################################
## SPADES ##
SPADES_OUTDIR=${OUTPUT_DIR}/spades/${SAMPLE_NAME}
mkdir -p ${SPADES_OUTDIR}

if ! [ -e "${SPADES_OUTDIR}/scaffolds.fasta" ]; then
    conda activate spades-4.2.0

    echo "$(date): SPADES ASSEMBLY"

    # regular spades (before using continue flag)
    spades.py \
        -1 ${FWD_READS} -2 ${REV_READS} \
        --meta --threads ${SLURM_CPUS_PER_TASK} \
        --memory 800 \
        --tmp-dir ${SPADES_OUTDIR}/temporary \
        -o ${SPADES_OUTDIR}

    # # spades with --continue (for jobs that failed due to time limit)
    # spades.py \
    # --continue \
    # -o ${SPADES_OUTDIR}

    echo "$(date): SPADES ASSEMBLY COMPLETE"

    conda deactivate
fi 
