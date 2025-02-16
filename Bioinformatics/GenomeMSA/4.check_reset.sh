#!/usr/bin/env bash

# purpose: to otain a segment of all resetted sequences - to compare them, see if they are similar 

reset_assemblies="output/reset_assemblies"

out_file=output/reset_check_result.tsv
truncate -s 0 ${out_file}  # empty the file (in case script is ran multiple times)

for assembly in $reset_assemblies/*; do
    name=`basename $assembly .fna`
    
    # obtain part of genomic sequence and append genome name to the front
    seq_snippet=`tail -n+2 $assembly | cut -c2000-2020 | sed "s/^/${name}\t/"`  

    echo "$seq_snippet" >> ${out_file} 

done