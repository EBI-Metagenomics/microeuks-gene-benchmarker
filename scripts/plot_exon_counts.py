import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import os

def plot_species(data, species, tool_order, tool_palette, output_folder):
    species_data = data[data['species'] == species].copy()  # Use .copy() to avoid SettingWithCopyWarning
    
    # Set ggplot2-style aesthetics
    sns.set(style="whitegrid")
    
    plt.figure(figsize=(12, 8))

    # Sort the data by tool for consistent color mapping
    species_data.loc[:, 'tool'] = pd.Categorical(species_data['tool'], categories=tool_order, ordered=True)

    sns.barplot(x='exons_per_gene', y='gene_counts', hue='tool', data=species_data, palette=tool_palette)
    
    # Set ggplot2-style axis and title formatting
    plt.title(f'Exon Counts for Species: {species}', fontsize=16, weight='bold')
    plt.xlabel('Number of exons per gene', fontsize=14)
    plt.ylabel('Gene counts', fontsize=14)
    plt.xticks(rotation=0, fontsize=12)
    plt.yticks(fontsize=12)
    plt.xlim(-0.5, 9.5)  # Limit x-axis to 10 exons
    
    # Move legend outside the plot
    plt.legend(title='Tool', title_fontsize=14, fontsize=12, loc='upper right', bbox_to_anchor=(1, 1))

    plt.tight_layout()

    output_file = os.path.join(output_folder, f'{species}_exon_counts.png')
    plt.savefig(output_file, bbox_inches='tight')  # Use bbox_inches='tight' to ensure nothing is cut off
    plt.close()

def main(input_file, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    data = pd.read_csv(input_file, delimiter='\t')

    # Extract species and tool information from column names
    columns = [col for col in data.columns if col != 'exons_per_gene']
    species_tools = [tuple(col.split('.')) for col in columns if '.' in col]

    # Remove duplicates
    species_tools = list(set(species_tools))

    melted_data = []
    for species, tool in species_tools:
        if species and tool:
            data_subset = data[['exons_per_gene', species + '.' + tool]].copy()
            data_subset.columns = ['exons_per_gene', 'gene_counts']
            data_subset['species'] = species
            data_subset['tool'] = tool
            melted_data.append(data_subset)

    melted_data = pd.concat(melted_data)

    # Get unique tools and create a fixed color palette
    unique_tools = sorted(melted_data['tool'].unique())  # Sorting the tools to ensure consistent order
    tool_palette = sns.color_palette('Set2', len(unique_tools))

    # Plot each species
    unique_species = melted_data['species'].unique()
    for species in unique_species:
        plot_species(melted_data, species, unique_tools, tool_palette, output_folder)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot exon counts for each species")
    parser.add_argument('-i', '--input', type=str, required=True, help='Input file path. Headers are expected to be in <species>.<tool> format')
    parser.add_argument('-o', '--output', type=str, required=True, help='Output folder path')
    args = parser.parse_args()

    main(args.input, args.output)
