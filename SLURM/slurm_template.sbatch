#!/usr/bin/env bash
#SBATCH --job-name JOB_NAME
#SBATCH --time 5-0  # time to allocate to job 
#SBATCH --partition PARTITION_NAME  # name of compute partition 
#SBATCH --cpus-per-task 1  # number of CPUS to request (threads ish)
#SBATCH --nodes 1  # number of node (usually only 1 unless using MPI)
#SBATCH --ntasks 1  # number of tasks (usually only 1)
#SBATCH --mem 1G

# #SBATCH --exclusive  # when requesting for an entire node

#SBATCH -o %j.out
#SBATCH -e %j.err

date

echo "SLURM Job ID: ${SLURM_JOB_ID}"
echo "CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"

eval "$(conda shell.bash hook)"
conda activate CONDA_ENV_NAME 

#codes here