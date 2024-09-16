#!/usr/bin/env python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import argparse

def plot_busco_completeness(file_path):
    columns = ['species', 'completeness_value', 'tool', 'busco_db']
    df = pd.read_csv(file_path, header=None, names=columns)
    df['completeness_value'] = pd.to_numeric(df['completeness_value'], errors='coerce')
    df['tool'] = df['tool'].str.replace('prot_', '', regex=False).str.capitalize()
    sns.set(style="whitegrid")
    plt.figure(figsize=(12, 8))
    sns.barplot(data=df, x='tool', y='completeness_value', hue='species', palette='Set2')
    plt.title('BUSCO completeness of the predicted proteins', fontsize=16, weight='bold', loc='left')
    plt.xlabel('Tool', fontsize=16)
    plt.ylabel('Completeness Value', fontsize=16)
    plt.xticks(rotation=0, fontsize=12)
    plt.yticks(rotation=0, fontsize=12)
    plt.legend(title='Species', bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.savefig("busco_completeness.png")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot BUSCO completeness of predicted proteins.")
    parser.add_argument('file_path', type=str, help='Path to the input CSV file')
    args = parser.parse_args()
    plot_busco_completeness(args.file_path)