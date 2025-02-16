#!/bin/sh
#SBATCH --job-name=blastn
#SBATCH --time 1-0  
#SBATCH -p PARTITION_NAME
#SBATCH -c 5
#SBATCH -N 1
#SBATCH --mem 5G
#SBATCH -o logs/blastn.%j.out
#SBATCH -e logs/blastn.%j.err

## DESCRIPTION ##
# Runs nucleotide BLAST on a list of files in provided path #
# Set up: 
    # edit $INPUT_FILE path on line 21
    # Create conda env with Blast installed 
        # conda create -n blast -c bioconda blast 

source activate blast

# path to list of files for BLAST 
INPUT_FILE="path/to/input/seq_paths.txt"

outdir="output"
mkdir -p ${outdir}

while read filepath; do
    # obtain file name
    fname=`basename "$filepath"`  

    # remove file extension 
    fname=${fname%.*}  
    
    # run blastn (using remote NCBI database)
    blastn \
        -query ${filepath} 
        -db nt -remote \
        -out ${outdir}/${fname}.tsv \
        -outfmt "6 qseqid sseqid qlen slen pident nident length mismatch gapopen qstart qend sstart send evalue bitscore scovhsp qcovhsp ssciname stitle"

done < ${INPUT_FILE}