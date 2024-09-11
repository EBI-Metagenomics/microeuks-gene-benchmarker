import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import os

def plot_species(data, species, output_folder):
    species_data = data[data['species'] == species]
    plt.figure(figsize=(10, 6))
    sns.barplot(x='exons_per_gene', y='gene_counts', hue='type', data=species_data, palette=['#1E90FF', '#FF6F61'])
    plt.title(f'Exon Counts for {species}')
    plt.xlabel('Number of exons per gene')
    plt.ylabel('Gene counts')
    plt.xticks(rotation=45)
    plt.legend(title='Legend', fontsize=12, title_fontsize=14)
    plt.tight_layout()
    output_file = os.path.join(output_folder, f'{species}_exon_counts.png')
    plt.savefig(output_file)
    plt.close()

def main(input_file, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    data = pd.read_csv(input_file, delimiter='\t')

    species_columns = [col for col in data.columns if col != 'exons_per_gene' and '_ref' not in col]
    ref_columns = [f"{col}_ref" for col in species_columns]
    all_columns = species_columns + ref_columns

    melted_data = pd.melt(data, id_vars=["exons_per_gene"], value_vars=all_columns, var_name='species', value_name='gene_counts')
    melted_data['type'] = melted_data['species'].apply(lambda x: 'Metaeuk' if 'ref' not in x else 'Reference')
    melted_data['species'] = melted_data['species'].str.replace('_ref', '')

    unique_species = melted_data['species'].unique()

    for species in unique_species:
        plot_species(melted_data, species, output_folder)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot exon counts for each species")
    parser.add_argument('-i', '--input', type=str, required=True, help='Input file path')
    parser.add_argument('-o', '--output', type=str, required=True, help='Output folder path')
    args = parser.parse_args()

    main(args.input, args.output)
