#!/usr/bin/env python3

from PIL import Image
import glob
import os
import argparse
import re

# What command did we choose
parser = argparse.ArgumentParser(
                    prog='stich_plate_photos.py',
                    description='arranges arrays of LTEE images',
                    epilog='')

parser.add_argument('-i', '--input', default='.', type=str)
parser.add_argument('-o', '--output', default='.', type=str)
parser.add_argument('-m', '--match', type=str)
#parser.add_argument('-o', '--output', default='.', type=str)


args = parser.parse_args()
input_path = args.input
output_path = args.output

print("Input directory path: " + input_path)

if args.match:
  print("  Input files must contain: " + args.match)

print("Output directory path: " + output_path)

os.makedirs(output_path, exist_ok=True) 

population_order = {
  'A-1' : 1,
  'A-2' : 2,
  'A-3' : 3,
  'A-4' : 4,
  'A-5' : 5,
  'A-6' : 6,
  'A+1' : 7,
  'A+2' : 8,
  'A+3' : 9,
  'A+4' : 10,
  'A+5' : 11,
  'A+6' : 12
}


# Look through and categorize files by the population they are in
# all other parts of the file name need to match. The part that matches the LTEE
# name will be replaced with "COMBINED" in the output file.

base_names = {}

existing_files=glob.glob(os.path.join(input_path,"*"))
if args.match:
  existing_files = [entry for entry in existing_files if args.match in entry]

for file_name in existing_files:
  if not re.search(r'\.(?:JPEG|JPG|GIF|PNG|TIFF)$', file_name.upper()):
    continue
  pop_match = re.search(r'(A-1|A-2|A-3|A-4|A-5|A-6|A\+1|A\+2|A\+3|A\+4|A\+5|A\+6)', file_name)
  if not pop_match:
    continue
  population_key = pop_match.group(0)
  file_name_key = re.sub(r'(A-1|A-2|A-3|A-4|A-5|A-6|A\+1|A\+2|A\+3|A\+4|A\+5|A\+6)', "COMBINED",file_name)

  #remove image number
  file_name_key = re.sub(r'_P\d+(\..+)$', "\1",file_name_key)

  #print(file_name_key)
  #print(population_key)

  if not file_name_key in base_names.keys():
    base_names[file_name_key] = {}
  base_names[file_name_key][population_key] = file_name

#print(base_names)

for combined_name_key in base_names.keys():
  print()
  print("===> Handling " + combined_name_key)
  print()

  if len(base_names[combined_name_key].keys()) != len(population_order.keys()):
    print("Did not find all expected files")
    print(base_names[combined_name_key].keys())
    print(population_order.keys())
    print()
    continue

  sorted_keys = sorted(base_names[combined_name_key].keys(), key=lambda x: population_order[x])
  print(sorted_keys)
  # Use width of first image as default
  img = Image.open(base_names[combined_name_key][sorted_keys[0]])
  img_size = img.size
  w = 6*img.size[0]
  h = 2*img.size[1]
  print('  Composite image dimensions','(',w,',',h,')')
  output_img = Image.new('RGB', (w,h), (250,250,250))

  image_index=0
  for file_key in sorted_keys:
    img = Image.open(base_names[combined_name_key][file_key])
    output_img.paste(img, (img.size[0]*(image_index % 6),img_size[1]*int(image_index/6)))
    image_index = image_index+1

  image_path = os.path.join(output_path, os.path.basename(combined_name_key + ".JPG"))
  print('  Saving image: ' + image_path)
  output_img.save(image_path, "JPEG", quality=100)
  
  # Save a smaller preview
  panel_size = 1200
  if (w > 6*panel_size):
    resized_image = output_img.resize((6*panel_size, 2*panel_size))
    preview_image_path = os.path.join(output_path, os.path.basename(combined_name_key + "_preview.JPG"))
    print('  Saving preview image: ' + preview_image_path)
    resized_image.save(preview_image_path, "JPEG", quality=100)

