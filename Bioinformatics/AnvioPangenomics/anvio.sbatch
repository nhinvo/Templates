#!/usr/bin/env bash
#SBATCH --job-name anvio_pangenomics
#SBATCH --time 12:00:00  # time to allocate to each array job 
#SBATCH --partition PARTITION_NAME  # name of compute partition 
#SBATCH --cpus-per-task 10  # number of CPUS to request per array job
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH --mem 100G
#SBATCH --array=1
#SBATCH -o logs/%j_%a.out
#SBATCH -e logs/%j_%a.err



## DESCRIPTION ##
# Runs Anvio Pangenomics workflow on a project directory with genomes #
# Set up: 
    # 1. Edit SBATCH --array to number of projects 
        # array=1 if only 1 project
        # project = a group of genomes to perform pangenomics analysis 
    # 2. Install Anvio following instructions on their website
        # Edit anvio Conda env name if different from "anvio"
    # 3. Create logs/ directory (mkdir logs) where this script is submitted 
    # 4. Edit ${MAIN_DIR} to path to folder containing projects
        # if 1 project: 
            # MAIN_DIR="main_dir" that contains a sub-project dir, e.g. main_dir/project_1
            # this script will run on genomes in main_dir/project_1/genomes
        # if multiple projects:
            # MAIN_DIR="main_dir" that contains many sub-project dir, e.g. main_dir/project_1, main_dir/project_2
    # 5. Edit paths to databases ${KEGG_DIR} & ${COG_DIR}
        # download script available: annot_db_prep.sbatch
    # (Optional) - functional enrichment: 
        # to perform functional enrichment: 
            # add file named `layer-additional-data.tsv` to project dir 
            # edit annotation source: ${FUNCTIONAL_ENRICHMENT_SOURCE} 
                # options (if you ran annot_db_prep.sbatch): COG20_FUNCTION, KOfam, COG20_CATEGORY, KEGG_BRITE, COG20_PATHWAY, KEGG_Class, KEGG_Module
        # e.g. main_dir/project_1/layer-additional-data.tsv
        # file should contain column 'isolate' with genome names, and any other columns with genome information 
        # e.g. ['isolate', 'depth'] to perform enrichment based on depth of samples 
    # 6. Submit script using `sbatch anvio.sbatch`
    
## ANVIO PANGENOMICS ## 

date
echo "SLURM Job ID: ${SLURM_JOB_ID}"
echo "Array index number: ${SLURM_ARRAY_TASK_ID} (out of: ${SLURM_ARRAY_TASK_MAX})"
echo "Array Job ID: ${SLURM_ARRAY_JOB_ID}"
echo "CPU Requested/Allocated for task: ${SLURM_CPUS_PER_TASK}"

eval "$(conda shell.bash hook)"
conda activate anvio

### INPUT PATHS ### 
MAIN_DIR=path/to/main_dir_containing_project_dir
KEGG_DIR=path/to/databases/anvio_kegg
COG_DIR=path/to/databases/anvio_cogs
FUNCTIONAL_ENRICHMENT_SOURCE="COG20_FUNCTION"

# obtain path to project dir 
dir_path=$(realpath ${MAIN_DIR}/* | sed -n ${SLURM_ARRAY_TASK_ID}p)
project_name=$(basename "$dir_path")  # obtain project name from path 

echo Performing Anvio Pangenomics on: ${project_name}... 

### Generate contig databases from genome fasta files ###
echo Generating Anvio contig databases from genome fasta files...
echo -e "$(date)\n"

for filepath in ${dir_path}/genomes/*.fasta; do 
    # genome name without extension 
    fname=$(basename "$filepath" .fasta)

    # if GENOME.db file doesn't already exists, execute command 
    if ! [ -e "${dir_path}/genomes/${fname}.db" ]; then
        echo Generating anvio contigs-db for: ${fname}...
        anvi-gen-contigs-database \
            --contigs-fasta ${filepath} \
            --project-name ${project_name} \
            --num-threads ${SLURM_CPUS_PER_TASK} \
            --output-db-path ${dir_path}/genomes/${fname}.db


        echo Performing KEGG annotation for: ${fname}...
        anvi-run-kegg-kofams \
            --contigs-db ${dir_path}/genomes/${fname}.db \
            --num-threads ${SLURM_CPUS_PER_TASK} \
            --kegg-data-dir ${KEGG_DIR}

        echo Performing COG annotation for: ${fname}...
        anvi-run-ncbi-cogs \
            --contigs-db ${dir_path}/genomes/${fname}.db \
            --num-threads ${SLURM_CPUS_PER_TASK} \
            --cog-data-dir ${COG_DIR}
    fi
done

echo Completed Anvio contig-db generation and annotation!
echo -e "$(date)\n"



### Generate genome storage ###
echo Generating Anvio genome storage...
echo -e "$(date)\n"

# if genome storage file doesn't already exists, execute command 
if ! [ -e "${dir_path}/${project_name}-GENOMES.db" ]; then
    anvi-gen-genomes-storage \
        --external-genomes ${dir_path}/external_genomes.tsv \
        --output-file ${dir_path}/${project_name}-GENOMES.db
fi

echo Completed genome storage generation
echo -e "$(date)\n"



### Running the pangenome analysis ### 
echo Performing Anvio Pangenome Analysis...
echo -e "$(date)\n"

# if pangenome database output doesn't already exist, execute command 
if ! [ -e "${dir_path}/${project_name}/${project_name}-PAN.db" ]; then
    anvi-pan-genome \
        -g ${dir_path}/${project_name}-GENOMES.db \
        --project-name ${project_name} \
        --output-dir ${dir_path}/${project_name} \
        --num-threads ${SLURM_CPUS_PER_TASK} \
        --use-ncbi-blast
fi

echo Completed Anvio Pangenome Analysis
echo -e "$(date)\n"

### Adding ANI analysis ### 
echo Performing fastANI...
echo -e "$(date)\n"

# if ANI output directory doesn't already exist, execute command 
if ! [ -d "${dir_path}/ANI" ]; then
    anvi-compute-genome-similarity \
        --external-genomes ${dir_path}/external_genomes.tsv \
        --pan-db ${dir_path}/${project_name}/${project_name}-PAN.db \
        --num-threads ${SLURM_CPUS_PER_TASK} \
        --log-file logs/ANI_${project_name}.err \
        --output-dir ${dir_path}/ANI
fi


echo Completed fastANI
echo -e "$(date)\n"


if [ -e "${dir_path}/layer-additional-data.tsv" ]; then
    # add layers (grouping) to samples 
    echo Adding Miscs layer data...
    echo -e "$(date)\n"
    
    anvi-import-misc-data \
        ${dir_path}/layer-additional-data.tsv \
        -p ${dir_path}/${project_name}/${project_name}-PAN.db \
        --target-data-table layers
        
    # perform functional enrichment
    echo Performing computational enrichment...
    functional_enrichment_dir=${dir_path}/functional_enrichment
    mkdir ${functional_enrichment_dir}
    
    anvi-compute-functional-enrichment-in-pan \
        -p ${dir_path}/${project_name}/${project_name}-PAN.db \
        -g ${dir_path}/${project_name}-GENOMES.db \
        --category-variable type \
        --annotation-source ${FUNCTIONAL_ENRICHMENT_SOURCE} \
        --output-file ${functional_enrichment_dir}/enriched-${FUNCTIONAL_ENRICHMENT_SOURCE}.tsv
    
    echo Completed functional enrichment! 
    echo -e "$(date)\n"

    
fi

# Example command to view Anvio Pangenome Output
# anvi-display-pan -g *GENOMES* -p */*-PAN.db
