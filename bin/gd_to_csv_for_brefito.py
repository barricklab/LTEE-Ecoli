#!/usr/bin/env python3

import csv
import os
import re
import argparse
from genomediff import GenomeDiff

def parse_gd_file(input_file):
    metadata = {}
    data = []

    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Open the file again for GenomeDiff (if needed)
    with open(input_file, 'r', encoding='utf-8') as f:
        gd = GenomeDiff.read(f)  

    # Ensure there are at least 10 lines
    #if len(lines) < 10:
    #    print(f"Skipping {input_file}: File has fewer than 10 lines")
    #    return None, None

    # Extract metadata dynamically by checking prefixes
    for line in lines:  # Only check first 10 lines
        if line.startswith("#=TITLE"):
            metadata["STRAIN"] = line.split("\t")[1].strip() if "\t" in line else "NA"
        elif line.startswith("#=TIME"):
            metadata["TIME"] = line.split("\t")[1].strip() if "\t" in line else "NA"
        elif line.startswith("#=POPULATION"):
            metadata["POPULATION"] = line.split("\t")[1].strip() if "\t" in line else "NA"
        elif line.startswith("#=TREATMENT"):
            metadata["TREATMENT"] = line.split("\t")[1].strip() if "\t" in line else "NA"
        elif line.startswith("#=CLONE"):
            metadata["CLONE"] = line.split("\t")[1].strip() if "\t" in line else "NA"
        elif line.startswith("#=MUTATOR_STATUS"):
            metadata["MUTATOR_STATUS"] = line.split("\t")[1].strip() if "\t" in line else "NA"

    # Ensure all metadata fields exist
    for key in ["STRAIN", "TIME", "POPULATION", "TREATMENT", "CLONE", "MUTATOR_STATUS"]:
        metadata.setdefault(key, "NA")

    # Extract URLs for REFSEQ and READSEQ

    readseq_urls_by_base_name = {}

    for line in lines:
        if line.startswith("#=REFSEQ"):
            parts = line.split("\t")
            if len(parts) > 1:
                refseq_url = parts[1].strip()
                data.append([metadata["STRAIN"], "reference", refseq_url])
        elif line.startswith("#=READSEQ"):
            parts = line.split("\t")
            if len(parts) > 1:
                readseq_url = parts[1].strip()
                readseq_base_name = re.sub(r"_(1|2)\.fastq\.gz", '_*.fastq.gz', readseq_url)
                if (not readseq_base_name in readseq_urls_by_base_name):
                    readseq_urls_by_base_name[readseq_base_name] = [readseq_url]
                else:
                    readseq_urls_by_base_name[readseq_base_name].append(readseq_url)
                #data.append([metadata["STRAIN"], "illumina", readseq_url])

    # Do a search to convert these to SRA and register paired reads
    
    for readseq_base_name, readseq_urls in sorted(readseq_urls_by_base_name.items()):
        sorted_readseq_urls = sorted(readseq_urls)
        if len(readseq_urls) == 2 and re.search(r"_1\.fastq\.gz", readseq_urls[0]) and re.search(r"_2\.fastq\.gz", readseq_urls[1]):

            sra_match = re.search(r"(E|SRR[0-9]+)_\*\.fastq\.gz", readseq_base_name)

            if sra_match:
                paired_read_seq_url = f"sra://{sra_match.group(1)}"
            else: 
                paired_read_seq_url = re.sub(r"_\*\.fastq\.gz", '_{1|2}.fastq.gz', readseq_base_name)

            data.append([metadata["STRAIN"], "illumina-PE", paired_read_seq_url])
        else:
            for readseq_url in sorted_readseq_urls:

                sra_match = re.search(r"(E|SRR[0-9]+)\.fastq\.gz", readseq_url)
                if sra_match:
                    readseq_url = f"sra://{sra_match.group(1)}"

                data.append([metadata["STRAIN"], "illumina-SE", readseq_url])

    # If no read files are included, don't include reference...prevents it from being in data.csv at all
    if len(readseq_urls_by_base_name.keys()) == 0:
        print(f"No read files found for '{input_file}'. Omitted from output data file.")
        data = []

    return metadata, data

def parse_gd_folder(folder_path, data_file, metadata_file):
    metadata_list = []
    data_list = []

    if not os.path.isdir(folder_path):
        print(f"Error: The folder '{folder_path}' does not exist.")
        return

    for filename in os.listdir(folder_path):
        if filename.endswith(".gd"):
            file_path = os.path.join(folder_path, filename)
            metadata, data = parse_gd_file(file_path)
            if metadata:
                metadata_list.append(metadata)
            if data:
                data_list.extend(data)
    print(f"Parsed *.gd files in '{folder_path}'")

    data_list.sort(key=lambda x: x[0])
    if data_list:
        with open(data_file, mode='w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["sample", "type", "setting"])
            writer.writerows(data_list)
    print(f"Data saved to '{data_file}'")

    metadata_list.sort(key=lambda x: (x["POPULATION"], float(x["TIME"]) if x["TIME"].replace('.', '', 1).isdigit() else float('inf'), x["CLONE"]))
    with open(metadata_file, mode='w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["STRAIN", "TIME", "POPULATION", "TREATMENT", "CLONE", "MUTATOR_STATUS"])
        writer.writeheader()
        writer.writerows(metadata_list)
    print(f"Metadata saved to '{metadata_file}'")
        

def main():
    parser = argparse.ArgumentParser(description="Parse *.gd files in a given directory and extract metadata and sequencing information.")
    parser.add_argument('-g', '--gd-path', help='Path to the input directory of *.gd files', required=True)
    parser.add_argument('-d', '--data-file', help='Path to the output data CSV file containing references/reads for brefito', default = 'data.csv')
    parser.add_argument('-m', '--metadata-file', help='Path to the output metadata CSV file containing sample information', default = 'metadata.csv')

    args = parser.parse_args()

    parse_gd_folder(args.gd_path, args.data_file, args.metadata_file)

if __name__ == '__main__':
    main()
