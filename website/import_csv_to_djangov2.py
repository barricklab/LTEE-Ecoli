your_djangoproject_home="your/directory/here"

import sys,os
sys.path.append(your_djangoproject_home)
os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'

import django
django.setup()
from mutations.models import Mutation

# This row deletes all previous values in the Model!
#Mutation.objects.all().delete()

import csv
import glob
import os.path
for filename in glob.glob('*.csv'):  
    dataReader = csv.reader(open(filename), delimiter=',', quotechar='"')
    for row in dataReader:
	    if row[0] != 'Start Position':
		    print(row)
		    this_mutation = Mutation()
		    this_mutation.start_position = row[0]
		    this_mutation.end_position = row[1]
		    this_mutation.mutation = row[2]
		    this_mutation.mutation_annotation = row[3]
		    this_mutation.gene_name = row[4]
		    this_mutation.gene_product = row[5]
		    this_mutation.time = row[6]
		    this_mutation.pop = row[7]
		    this_mutation.clone = row[8]
		    this_mutation.save()

#glob is the only thing that has really changed substantially here, it allows import of all csv files in the same directory