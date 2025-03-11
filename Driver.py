#!/usr/bin/env python3

import csv
import os
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
    if len(lines) < 10:
        print(f"Skipping {input_file}: File has fewer than 10 lines")
        return None, None

    # Extract metadata dynamically by checking prefixes
    for line in lines[:10]:  # Only check first 10 lines
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
                data.append([metadata["STRAIN"], "illumina", readseq_url])

    return metadata, data

def parse_gd_folder(folder_path):
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

    metadata_list.sort(key=lambda x: (x["POPULATION"], float(x["TIME"]) if x["TIME"].replace('.', '', 1).isdigit() else float('inf'), x["CLONE"]))
    data_list.sort(key=lambda x: x[0])

    metadata_csv_path = os.path.join(folder_path, 'metadata.csv')
    with open(metadata_csv_path, mode='w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["STRAIN", "TIME", "POPULATION", "TREATMENT", "CLONE", "MUTATOR_STATUS"])
        writer.writeheader()
        writer.writerows(metadata_list)

    if data_list:
        data_csv_path = os.path.join(folder_path, 'data.csv')
        with open(data_csv_path, mode='w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["sample", "type", "setting"])
            writer.writerows(data_list)

    print(f"Metadata saved to {metadata_csv_path}")
    if data_list:
        print(f"Data saved to {data_csv_path}")

def main():
    parser = argparse.ArgumentParser(description="Parse .gd files in a given directory and extract metadata and sequencing information.")
    parser.add_argument("folder_path", help="Path to the directory containing .gd files")
    args = parser.parse_args()

    parse_gd_folder(args.folder_path)

if __name__ == '__main__':
    main()
