"""
Purpose: to obtain ANI between all reads and plot 
ANI distribution. 
"""
import pandas as pd 
from pathlib import Path 

def parse_skani_result(fpath):
    """
    """
    outdir = "output"

    df = pd.read_table(fpath)[['ANI', 'Align_fraction_ref', 'Align_fraction_query']]

    ANI_counts_df = df['ANI'].value_counts()
    ANI_counts_df.to_csv(f'{outdir}/parsed_skani_reads.tsv', sep='\t', index=False)

    return df

def histogram(df):
    """
    """
    outdir = "output"

    ANImin = df['ANI'].min()
    ANImax = df['ANI'].max()

    ax = df.plot.hist(column=['ANI'], bins=100, xlim=(ANImin, ANImax), figsize=(5, 5))
    fig = ax.get_figure()
    fig.savefig(f'{outdir}/skani_reads_histogram.png')

    # clear figure after 
    ax.clear()

def main():
    skani_reads_fpath = "output/skani-reads-out.tsv"
    
    # obtain df of results
    df = parse_skani_result(skani_reads_fpath)

    # plot data distribution 
    histogram(df, dataset_name)

if __name__ == "__main__":
    main()