import sys,os

script_path = os.path.dirname(os.path.realpath(__file__))

djangoproject_home= os.path.join(script_path, '..')
sys.path.append(djangoproject_home)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "LTEE_Ecoli_site.settings")

import django
django.setup()

from LTEE_Ecoli.models import Mutation

# This row deletes all previous values in the Model!
Mutation.objects.all().delete()

import csv
import glob
for filename in glob.glob('csv/*.csv'):  
    print '===> FILE:', filename
    dataReader = csv.reader(open(filename), delimiter=',', quotechar='"')
    for row in dataReader:
        print row
        if row[0] != 'Start_Position':
            print(row)
            this_mutation = Mutation()
            this_mutation.start_position = row[0]
            this_mutation.end_position = row[1]
            this_mutation.mutation = row[2]
            this_mutation.mutation_annotation = row[3]
            this_mutation.gene_name = row[4]
            this_mutation.gene_product = row[5]
            this_mutation.generation = row[6]
            this_mutation.population = row[7]
            this_mutation.clone = row[8]
            this_mutation.save()

#glob is the only thing that has really changed substantially here, it allows import of all csv files in the same directory
