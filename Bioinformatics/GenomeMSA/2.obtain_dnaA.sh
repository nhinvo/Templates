#!/usr/bin/env bash
# purpose: to obtain dnaA information from gff files of all annotated assemblies 

# path to input dir (i.e. output dir of annotation in step 1)
annotation_out="output/annotated-genomes"

# paths to output 
mkdir -p output/dnaA_info
dnaA_out="output/dnaA_info/all_dnaA_gff.tsv"
dnaA_count_out="output/dnaA_info/dnaA_count.tsv"

# empty the file (in case script is ran multiple times)
truncate -s 0 ${dnaA_out} 
truncate -s 0 ${dnaA_count_out}

date
for gff in ${annotation_out}/*/*.gff; do 
    # obtain assembly name and remove extension 
    name=`basename $gff .gff`  

    # dnaA row from gff + add assembly name 
    dnaA_info=`grep 'dnaA' ${gff} | sed "s/^/${name}\t/" | head -n1` 
    
    # number of dnaA genes in genome 
    dnaA_count=`grep 'dnaA' ${gff} | wc -l | sed "s/^/${name}\t/"`  

    # save data
    echo "$dnaA_info" >> ${dnaA_out}
    echo "$dnaA_count" >> ${dnaA_count_out}

done 

echo Complete!
date