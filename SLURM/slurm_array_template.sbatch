#!/usr/bin/env bash
#SBATCH --job-name JOB_NAME
#SBATCH --time 5-0  # time to allocate to each array job 
#SBATCH --partition PARTITION_NAME  # name of compute partition 
#SBATCH --cpus-per-task 1  # number of CPUS to request per array job
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH --mem 1G

#SBATCH --array=ARRAY_START_NUM-ARRAY_END_NUM%INCREMENT_NUM  # e.g. 1-10%5 (1 to 10 by 5)

#SBATCH -o log-%j_%a.out
#SBATCH -e log-%j_%a.err

date

echo "SLURM Job ID: ${SLURM_JOB_ID}"
echo "Array index number: ${SLURM_ARRAY_TASK_ID} (out of: ${SLURM_ARRAY_TASK_MAX})"
echo "Array Job ID: ${SLURM_ARRAY_JOB_ID}"
echo "CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"

# activate any conda environment neccesary 
eval "$(conda shell.bash hook)"
conda activate ENV_NAME

# 2 methods to access files using SLURM arrays: 

## 1. using array from a sample.tsv file:
sample_path=$(sed "${SLURM_ARRAY_TASK_ID}q;d" sample.tsv | cut -f1 | tr -d '\r')

## 2. using array on a directory of samples
sample_path=$(realpath path/to/files/* | sed -n ${SLURM_ARRAY_TASK_ID}p)
