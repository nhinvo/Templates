"""
Purpose: to parse output from Kaiju

Set up: 
    - Install Pandas
"""
import pandas as pd 
from pathlib import Path 

def main():
    kaiju_outdir = Path('data/refseq_kaiju_out')
    dfs = []

    # parse genus summary files 
    for genus_summary_fpath in kaiju_outdir.glob('*genus*'):
        df = pd.read_table(genus_summary_fpath)
        df = df.sort_values(by=['percent'], ascending=False)
        df = df.head(1)
        df['sample'] = df['file'].str.split('/').str[2].str.split('_').str[0]
        df = df[['sample', 'percent', 'taxon_name']]
        df = df.rename(columns={'percent': 'kaiju_percent', 'taxon_name': 'kaiju_classification'})
        dfs.append(df)

    # combine classification from all files/samples
    df = pd.concat(dfs)

    df.to_csv('output/parsed-classification.tsv', sep='\t', index=False)
    df.to_excel('data/parsed-classification.xlsx', index=False)

if __name__ == "__main__":
    main()