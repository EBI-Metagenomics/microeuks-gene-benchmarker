import argparse

def parse_stats(stats_file, sample_id):
    with open(stats_file, 'r') as stats_in, open(f'{sample_id}.f1_scores', 'w') as stats_out:
        for line in stats_in:
            if not line.startswith('#') and line.strip():
                if  'Matching' in line:
                    break
                data = line.rstrip()
                feature = data.split(':')[0]
                remaining_data = data.split(':')[1]
                sensitivity = float(remaining_data.split('|')[0])
                precision = float(remaining_data.split('|')[1])
                f1_score = 2*(precision * sensitivity)/(precision + sensitivity)
                stats_out.write(
                    f'{sample_id}\t{feature}\t{sensitivity}\t{precision}\t{f1_score}\n'
                )

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="script to rename gff and gtf inputs from eukaryotic gene annotators")
    parser.add_argument("-s", "--sample")
    parser.add_argument("-f", "--stats_file")
    args = parser.parse_args()
    parse_stats(args.stats_file, args.sample)

