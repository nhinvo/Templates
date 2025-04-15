"""
Purpose: to prepare genomes for Anvio Pangenomics Analysis. 

04/15/2025
"""
import os
import argparse
import pandas as pd 
from pathlib import Path 

## Command line arguments 
parser = argparse.ArgumentParser()

# required parameters/inputs:
parser.add_argument("genome_dir", help="Path to directory containing genome fasta files for pangenomic analysis.")
parser.add_argument("output_dir", help="Path to directory for output external_genomes.tsv.")
# optional parameters/inputs:
parser.add_argument("--extension", help="Extension of genome files (i.e. fasta, fna, fa). Default=fasta") 

args = parser.parse_args()

## Obtain command line inputs 
GENOME_DIR = args.genome_dir
GENOME_EXTENSION = 'fasta' if not args.extension else args.extension
OUTPUT_DIR = args.output_dir

def main():
    anvio_data = {
        'name': [], 
        'contigs_db_path': [], 
    }

    for fpath in Path(GENOME_DIR).glob(f'*.{GENOME_EXTENSION}'):
        # obtain full path to the genome directory 
        genome_dir = fpath.parent
        genome_dir = os.path.realpath(genome_dir)

        # obtain genome name 
        sname = fpath.stem
        
        # create path to Anvio .db file (to be created later)
        db_path = f'{genome_dir}/{sname}.db'

        anvio_data['name'].append(sname)
        anvio_data['contigs_db_path'].append(db_path)

    df = pd.DataFrame(anvio_data)
    
    df.to_csv(f'{OUTPUT_DIR}/external_genomes.tsv', sep='\t', index=False)

main()