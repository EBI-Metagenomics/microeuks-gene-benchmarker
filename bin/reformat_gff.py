import sys
import argparse

def num_underscores(ref_gff):
    with open(ref_gff, 'r') as reference:
        for line in reference:
            if not line.startswith('#'):
                scaffold = line.split('\t')[0]
                underscore_num = scaffold.count('_')
                return underscore_num + 1

def reformat_metaeuk(gff, sample_id):
    with open(gff, 'r') as metaeuk_gff_in, open(f'{sample_id}.metaeuk.reformatted.gff', 'w') as metaeuk_gff_out:
        gff_contents = metaeuk_gff_in.read()
        gff_contents = gff_contents.replace("Target_ID=", "ID=")
        metaeuk_gff_out.write(gff_contents)

def reformat_galba_braker(gtf, underscore_count, sample_id, tool_id):
    with open(gtf, 'r') as galba_gtf_in, open(f'{sample_id}.{tool_id}.reformatted.gtf', 'w') as galba_gtf_out:
        for line in galba_gtf_in:
            scaffold = line.split('\t')[0]
            line_data = '\t'.join(line.split('\t')[1:])
            simplified = '_'.join(scaffold.split('_')[0:underscore_count])
            galba_gtf_out.write(f'{simplified}\t{line_data}')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="script to rename gff and gtf inputs from eukaryotic gene annotators to match the reference gff")
    parser.add_argument("-s", "--sample")
    parser.add_argument("-r", "--ref_gff")
    parser.add_argument("-g", "--galba_gtf")
    parser.add_argument("-b", "--braker_gtf")
    parser.add_argument("-m", "--metaeuk_gff")
    args = parser.parse_args()
    sep_num = num_underscores(args.ref_gff)
    if args.metaeuk_gff:
        reformat_metaeuk(args.metaeuk_gff, args.sample)
    if args.galba_gtf:
        reformat_galba_braker(args.galba_gtf, sep_num, args.sample, 'galba')
    if args.braker_gtf:
        reformat_galba_braker(args.braker_gtf, sep_num, args.sample, 'braker')
    

