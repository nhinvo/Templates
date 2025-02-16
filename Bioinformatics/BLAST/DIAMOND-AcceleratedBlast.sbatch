#!/bin/sh
#SBATCH --job-name=diamond-blast
#SBATCH --time 1-0  
#SBATCH -p PARTITION_NAME
#SBATCH -c 5
#SBATCH -N 1
#SBATCH --mem 5G
#SBATCH -o logs/diamond-blast.%j.out
#SBATCH -e logs/diamond-blast.%j.err

## DESCRIPTION ##
# Runs DIAMOND BLAST #
# Set up: 
    # Create conda env with Blast installed 
        # conda create -n diamond-blast -c bioconda diamond 
    # Edit paths to: $INPUT_FILE, $GENOME_DIR, $PROTEIN_DATABASE

source activate diamond-blast

# path to file of genome names for blasting
INPUT_FILE="path/to/genome/names.txt"

# path to folder of genomes to blast for sequence
GENOME_DIR="path/to/genome/dir"

# path to protein database to perform Blast comparison 
PROTEIN_DATABASE="path/to/protein.file/file.faa"

# output direcory 
outdir="path/to/output/dir"

# 1. Make Blast protein database 
diamond makedb \
    --in ${PROTEIN_DATABASE} \
    --db ${PROTEIN_DATABASE}


# 2. Cycle through each genome and perform diamond blast 
while read name; do
    echo Performing DIAMOND Blast on: $name
    date

    diamond blastp \
        --query ${genomes}/${name}/${name}.genes.faa \
        --db $PROTEIN_DATABASE --out ${outdir}/${name}.tsv \
        --outfmt 6 qseqid sseqid qlen slen pident nident length mismatch gapopen qstart qend sstart send evalue bitscore full_sseq full_qseq scovhsp qcovhsp

done < $INPUT_FILE

