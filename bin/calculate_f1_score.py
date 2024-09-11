#!/usr/bin/env python3

import argparse


def tool_detector(filepath):
    with open(filepath, 'r') as stats_in:
        for line in stats_in:
            print(line)
            if '#gffcompare' in line:
                if 'metaeuk' in line or 'MetaEuk' in line:
                    return 'metaeuk'
                elif 'braker' in line or 'BRAKER' in line or 'Braker' in line:
                    return 'braker'
                elif 'galba' in line or 'GALBA' in line or 'Galba' in line:
                    return 'galba'
                else:
                    print('No tool detected')
                    exit(1)


def parse_stats(stats_file, sample_id, tool_id):
    with open(stats_file, 'r') as stats_in, open(f'{sample_id}.{tool_id}.f1_scores', 'w') as stats_out:
        for line in stats_in:
            if not line.startswith('#') and line.strip():
                if 'Matching' in line:
                    break
                data = line.rstrip()
                feature = data.split(':')[0]
                remaining_data = data.split(':')[1]
                sensitivity = float(remaining_data.split('|')[0])
                precision = float(remaining_data.split('|')[1])
                if precision + sensitivity == 0:
                    f1_score = 0
                else:
                    f1_score = 2*(precision * sensitivity)/(precision + sensitivity)
                stats_out.write(
                    f'{sample_id}\t{tool_id}\t{feature}\t{sensitivity}\t{precision}\t{f1_score}\n'
                )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Script to calculate F1 score from gffcompare")
    parser.add_argument("-s", "--sample")
    parser.add_argument("-t", "--tool", required=False)
    parser.add_argument("-f", "--stats_file")
    args = parser.parse_args()
    if args.tool:
        tool = args.tool
    else:
        tool = tool_detector(args.stats_file)
    parse_stats(args.stats_file, args.sample, tool)


