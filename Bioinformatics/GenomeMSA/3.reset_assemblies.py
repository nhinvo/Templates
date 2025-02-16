"""
Purpose: to rearrange assembly - move dnaA gene to the front for downstream alignment

Set up: 
    - create conda environment with Pandas and BioPython 
        - conda create -n parse -c conda-forge -c anaconda biopython pandas
    - edit path to all assemblies on line 16 
"""
from pathlib import Path
import pandas as pd
from Bio import SeqIO
from Bio.Seq import Seq

# input paths:
gff_path = "output/dnaA_info/all_dnaA_gff.tsv"
all_assemblies_path = Path("path/to/genome_dir")  # EDIT PATH 

# output paths:
reset_assemblies_path = Path("output/reset_assemblies")
Path(reset_assemblies_path).mkdir(parents=True, exist_ok=True)

# 1. Obtain coordinate information for each genome: 
cdf=pd.read_csv(gff_path, sep='\t', names=[
    'concat_genome_name',
    'chromosome',
    'source',
    'type',
    'start',
    'end',
    'score',
    'strand',
    'phase',
    'attributes'
], usecols=['concat_genome_name', 'chromosome', 'start', 'end', 'strand', 'attributes'], index_col=['concat_genome_name'])

# 2. separate assemblies by strand (each strand is processsed differently):
data={}  # {'plus':df, 'minus':df}
strand_groups=cdf.groupby(['strand'])
for name, group in strand_groups:
    strand=name[0]
    if strand=='+':
        data['plus']=group
    elif strand=='-':
        data['minus']=group

# 4. Process minus(-) strands:
df=data['minus']
assemblies=df.index.to_list()
dnaA_end=df.end.to_list()
plus_data=dict(zip(assemblies, dnaA_end))  # {'assembly name':dnaA start}

for assembly_name, dnaA_end in plus_data.items():
    assembly_path=all_assemblies_path/f"{assembly_name}.fasta"  # path to fasta
    record_dict=SeqIO.to_dict(SeqIO.parse(assembly_path, 'fasta'))  # import fasta sequence 
    chromosome=list(record_dict.keys())[0]  # obtain chromosome/contig name (there's only 1)
    seq=record_dict[chromosome].seq  # obtain assembly/sequence 
    
    # rearrange sequence:
    reset_seq=seq[(dnaA_end-1):]+seq[0:(dnaA_end)]
    reset_seq=reset_seq.reverse_complement()

    # save seq
    file = open(f"{reset_assemblies_path}/{assembly_name}.fna", 'w+')
    file.write(f">{assembly_name}\n")
    file.write(str(reset_seq))




