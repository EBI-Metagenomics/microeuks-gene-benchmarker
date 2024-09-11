import argparse
from collections import Counter
import os

def count_exons_per_gene(gff_file):
    exon_count = []
    gene = None
    with open(gff_file, 'r') as file:
        for line in file:
            if line.startswith("#"):
                continue  # Skip header lines
            columns = line.strip().split('\t')
            if len(columns) < 9:
                continue  # Skip incomplete lines
            
            feature_type = columns[2]

            if feature_type == "gene":
                if gene:

                    exon_count.append(n_exons)
                    n_exons = 0
                    gene = None
                gene = True
                n_exons = 0
            
            elif feature_type == "exon":
                if gene:
                    n_exons += 1 
        if gene:
            exon_count.append(n_exons)

    return Counter(exon_count)


def merge_exon_counts(exon_counter):
    merged_counts = {}

    # Get a list of all unique exon numbers across all files
    all_exon_numbers = set()
    for exon_counts in exon_counter:
        all_exon_numbers.update(exon_counts.keys())
    
    # Initialize merged counts with zero for each exon number
    for exon_number in all_exon_numbers:
        merged_counts[exon_number] = [0] * len(exon_counter)
    
    # Fill in counts for each exon number in each file
    for idx, exon_counts in enumerate(exon_counter):
        for exon_number, count in exon_counts.items():
            merged_counts[exon_number][idx] = count
    
    return merged_counts

def write_output(output_file, labels, merged_counts):
    with open(output_file, 'w') as f:
        # Write header
        f.write("exons_per_gene\t" + "\t".join(labels) + "\n")
        
        # Write counts for each exon number
        for exon_number, counts in sorted(merged_counts.items()):
            f.write(f"{exon_number}\t" + "\t".join(map(str, counts)) + "\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Count the number of exons per gene from multiple GFF3 files and summarize the counts in a table.'
    )
    parser.add_argument('gff_files', nargs='+', help='Input GFF3 files (space-separated)')
    parser.add_argument('-o', '--output', default='exon_counts_combined.txt', help='Output file name (default: exon_counts_combined.txt)')
    parser.add_argument('-l', '--label', default=None, help='Comma-separated labels for the table columns')
    args = parser.parse_args()

    # Process each GFF file
    exon_counts = []
    for gff_file in args.gff_files:
        exon_counts.append(count_exons_per_gene(gff_file))

    # Merge counts from all files
    merged_counts = merge_exon_counts(exon_counts)

    # Get labels for the columns
    if args.label:
        labels = args.label.split(',')
        if len(labels) != len(args.gff_files):
            raise ValueError("The number of labels must match the number of GFF files.")
    else:
        # Use filenames without extensions as labels if no labels are provided
        labels = [os.path.splitext(os.path.basename(gff_file))[0] for gff_file in args.gff_files]

    # Write the combined output to the specified file
    write_output(args.output, labels, merged_counts)
