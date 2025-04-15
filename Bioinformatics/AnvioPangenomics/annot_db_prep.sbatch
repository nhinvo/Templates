#!/usr/bin/env bash
#SBATCH --job-name anvio_db_dl
#SBATCH --time 12:00:00  # time to allocate to each array job 
#SBATCH --partition PARTITION_NAME  # name of compute partition 
#SBATCH --exclusive  # request entire node 
#SBATCH --cpus-per-task CPU_NUM  # edit to HPC node specification 
#SBATCH --mem 0  # entire node's mem 
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH -o logs/db_dl-%j.out
#SBATCH -e logs/db_dl-%j.err

## DESCRIPTION ##
# Runs Anvio Pangenomics workflow on a project directory with genomes #
# Set up: 
    # 1. Edit SBATCH specifications 
    # 2. Install Anvio following instructions on their website
        # Edit anvio Conda env name if different from "anvio"
    # 3. Create logs/ directory (mkdir logs) where this script is submitted 
    # 4. Edit output paths to databases ${KEGG_DIR} & ${COG_DIR}
    # 5. Submit script using `sbatch annot_db_prep.sbatch`
    
    
## ANVIO DOWNLOAD DB ## 

# Input paths #
KEGG_DIR=path/to/databases/anvio_kegg
COG_DIR=path/to/databases/anvio_cogs

date

echo "SLURM Job ID: ${SLURM_JOB_ID}"
echo "CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"

eval "$(conda shell.bash hook)"
conda activate anvio

# Database download #
rm -r ${KEGG_DIR}  # remove dir if already exists (else Anvio won't run)
anvi-setup-kegg-data \
    --num-threads ${SLURM_CPUS_PER_TASK} \
    --kegg-data-dir ${KEGG_DIR}


rm -r ${COG_DIR}  # remove dir if already exists (else Anvio won't run)
anvi-setup-ncbi-cogs \
    --num-threads ${SLURM_CPUS_PER_TASK} \
    --cog-data-dir ${COG_DIR}