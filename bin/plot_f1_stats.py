#!/usr/bin/env python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import argparse

def plot_f1_scores(file_path):
    columns = ['sample', 'tool', 'feature', 'sensitivity', 'precision', 'f1']
    df = pd.read_table(file_path, header=None, names=columns)
    df['feature'] = df['feature'].str.strip().str.replace('level', '').str.replace(' ', '')
    
    # Create subplots with a shared y and x axis
    fig, axs = plt.subplots(2, 2, figsize=(10, 10), sharey=True, sharex=True)
    axs_flat = axs.ravel()  # Flatten the axes array for easier access
    fig_index = 0
    features = ['Base', 'Exon', 'Intron', 'Transcript']
    
    # Iterate over features and plot on shared axis
    for f in features:
        subset_df = df[df["feature"] == f]
        sns.scatterplot(data=subset_df, 
                        x='sensitivity', 
                        y='precision', 
                        hue='sample', 
                        style='tool', 
                        s=100, 
                        ax=axs_flat[fig_index],
                        legend=(fig_index == 0))  # Keep legend for only the first plot
        if fig_index == 0:
            handles, labels =axs_flat[fig_index].get_legend_handles_labels()
        
        axs_flat[fig_index].set_title(f)  
        axs_flat[fig_index].set_xlabel('Sensitivity')  
        axs_flat[fig_index].set_ylabel('Precision')  
        axs_flat[fig_index].tick_params(axis='x', rotation=0, labelsize=12)  
        axs_flat[fig_index].tick_params(axis='y', rotation=0, labelsize=12) 
        fig_index += 1    
    

    plt.tight_layout()
    plt.savefig("f1_stats.pdf")
         
  

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot specificty and precision per feature type")
    parser.add_argument('file_path', type=str, help='Path to the input CSV file')
    args = parser.parse_args()
    plot_f1_scores(args.file_path)


