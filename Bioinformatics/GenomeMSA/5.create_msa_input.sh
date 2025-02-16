#!/usr/bin/env bash

# Purpose: to group assembly contigs of each group into 1 fasta file for msa 
# Set up: 
    # - Create a msa_samples.tsv file with 2 columns:
        # - name: name of MSA
        # - filepaths: ' ' separated string of fasta file for MSA

samples=path/to/msa_samples/msa_samples.tsv

outdir=output/msa_inputs
mkdir -p ${outdir}

{
    read  # skip header/col name 
    while read line; do 
        # obtain msa name
        ID=`echo "$line" | cut -d'	' -f1`  

        # obtain file paths to combine
        files=`echo "$line" | cut -d'	' -f2`  
        
        # combine files 
        awk '{print}' $files > "${outdir}/${ID}.fna"
    done
} < $samples


echo Done!