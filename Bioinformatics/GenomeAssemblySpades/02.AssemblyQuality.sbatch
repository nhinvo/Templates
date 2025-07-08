#!/usr/bin/env bash
#SBATCH --job-name MAG-Quality

#SBATCH --time 12:00:00
#SBATCH --partition PARTITION_NAME 
#SBATCH --cpus-per-task 24
#SBATCH --nodes 1  
#SBATCH --ntasks 1  
#SBATCH --mem 190000
#SBATCH --array=1-3%3

#SBATCH -o logs/AssemblyQuality/%a-%j.out
#SBATCH -e logs/AssemblyQuality/%a-%j.err


#######################################################
## DESCRIPTION ##
# Runs Spades genome assembly #
# Set up: 
    # 1. Edit SBATCH specifications above 
    # 2. Install conda environment: 
        # bbmap-39.26: with bbmap v.39.26
            # conda create -n bbmap-39.26 -c bioconda bbmap=39.26
        # samtools-1.22: with samtools v.1.22
        # metabat2-2.18: with metabat2 v.2.18
        # gtdbtk-2.4.1: with gtdbtk v.2.4.1
    # 3. Create logs/AssemblyQuality/ directory where this script will be submitted 
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

CHECKM_DB=path/to/CheckM/database
GTDB_DB=path/to/GTDB/database

# OUTPUT 
OUTPUT_DIR=path/to/output_dir
mkdir -p ${OUTPUT_DIR}


########################################################################################
## READ MAPPING ## 
MAPPING_OUTDIR=${OUTPUT_DIR}/read_mapping
mkdir -p ${MAPPING_OUTDIR}

SPADES_OUTDIR=${OUTPUT_DIR}/spades/${SAMPLE_NAME}  # assembly input dir 

if ! [ -e "${MAPPING_OUTDIR}/${SAMPLE_NAME}.sam" ]; then
    conda activate bbmap-39.26

    echo "$(date): READ MAPPING STEP" 

    bbmap.sh \
        ref=${SPADES_OUTDIR}/scaffolds.fasta \
        in=${FWD_READS} in2=${REV_READS} \
        out=${MAPPING_OUTDIR}/${SAMPLE_NAME}.sam \
        nodisk=t threads=${SLURM_CPUS_PER_TASK}
    
    echo "$(date): Completed bbmap read mapping" 

    conda deactivate 
fi 


########################################################################################
## SAMTOOLS ##
conda activate samtools-1.22

# convert sam to bam
if ! [ -e "${MAPPING_OUTDIR}/${SAMPLE_NAME}_unsorted.bam" ]; then
    echo "$(date): Running SAM to BAM conversion..."

    samtools view \
        --bam \
        --threads ${SLURM_CPUS_PER_TASK} \
        --output ${MAPPING_OUTDIR}/${SAMPLE_NAME}_unsorted.bam \
        ${MAPPING_OUTDIR}/${SAMPLE_NAME}.sam
    
    echo "$(date): SAM to BAM complete... "
fi 

# sort bam 
if ! [ -e "${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam" ]; then
    echo "$(date): Running BAM sort..." 

    samtools sort \
        --threads ${SLURM_CPUS_PER_TASK} \
        -o ${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam \
        ${MAPPING_OUTDIR}/${SAMPLE_NAME}_unsorted.bam
        
    echo "$(date): Complete BAM sort..." 
fi 

# index the sorted_bam
if ! [ -e "${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam.bai" ]; then
    echo "$(date): Indexing sorted BAM file..."

    samtools index \
        --threads ${SLURM_CPUS_PER_TASK} \
        --bai \
        --output ${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam.bai \
        ${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam

    echo "$(date): Completed BAM indexing"
fi 

conda deactivate 


########################################################################################
## METABAT2 BINNING ##
conda activate metabat2-2.18

BINNING_OUTDIR=${OUTPUT_DIR}/metabat2_binning/${SAMPLE_NAME}
mkdir -p ${BINNING_OUTDIR}

# Generate depth file from bam file 
if ! [ -e "${BINNING_OUTDIR}/${SAMPLE_NAME}_depth.txt" ]; then
    echo "$(date): Running JGI Depth..."

    jgi_summarize_bam_contig_depths \
        --outputDepth ${BINNING_OUTDIR}/${SAMPLE_NAME}_depth.txt \
        ${MAPPING_OUTDIR}/${SAMPLE_NAME}_sorted.bam

    echo "$(date): Completed JGI Depth"
fi 

# Run metabat2 
if ! [ -e "${BINNING_OUTDIR}/${SAMPLE_NAME}.BinInfo.txt" ]; then
    echo "$(date): Running Metabat2 binning..."

    metabat2 \
        --inFile ${SPADES_OUTDIR}/scaffolds.fasta \
        --numThreads ${SLURM_CPUS_PER_TASK} \
        --abdFile ${BINNING_OUTDIR}/${SAMPLE_NAME}_depth.txt \
        --outFile ${BINNING_OUTDIR}/${SAMPLE_NAME}
    
    echo "$(date): Metabat2 binning completed" 
fi 

conda deactivate 


########################################################################################
## CHEKM2 QUALITY CHECK ## 
CHECKM2_OUTDIR=${OUTPUT_DIR}/checkm_bin_quality

if ! [ -e "${CHECKM2_OUTDIR}/${SAMPLE_NAME}/quality_report.tsv" ]; then
    conda activate checkm2-1.1.0

    echo "$(date): Running checkm2..."

    checkm2 predict \
        --threads ${SLURM_CPUS_PER_TASK} \
        --database_path ${CHECKM_DB} \
        --force --remove_intermediates \
        --input ${BINNING_OUTDIR} --extension fa \
        --output-directory ${CHECKM2_OUTDIR}/${SAMPLE_NAME} 
    
    echo "$(date): checkm2 completed"
fi 


########################################################################################
## GTDB CLASSIFICATIOB ## 
GTDB_OUTDIR=${OUTPUT_DIR}/gtdb_classification/${SAMPLE_NAME}  
mkdir -p ${GTDB_OUTDIR}

# run GTDB-tk classifier 
if ! [ -e "${GTDB_OUTDIR}/gtdbtk.bac120.summary.tsv" ]; then
    conda activate gtdbtk-2.4.1

    echo "$(date): Running GTDB Classification"
    
    # set database path for GTDB-tk 
    export GTDBTK_DATA_PATH=${GTDB_DB}; 

    gtdbtk classify_wf \
        --cpus ${SLURM_CPUS_PER_TASK} \
        --genome_dir ${BINNING_OUTDIR} \
        --extension fa \
        --skip_ani_screen \
        --force \
        --out_dir ${GTDB_OUTDIR}

    echo "$(date): GTDB Classification completed"

    conda deactivate 
fi 


echo "$(date): ASSEMBLY QUALITY COMPLETE!!"
    
