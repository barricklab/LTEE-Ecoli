#!/usr/bin/env python

import re
import csv
import sys
import os
import glob
import itertools

for filename in glob.glob('*.gd'):
    file = open(filename)
    originalgdname = os.path.splitext(filename)[0]
    print(originalgdname)
    startpos = []
    endpos = []
    mutation = []
    mutationannotation = []
    genename = []
    geneproduct = []
    time = []
    pop = []
    clone = []

#glob applies all of the code to all .gd files in the same directory the script is in
#sets up empty lists to deposit re.findall() results into
	
    for line in file:
        x = re.findall('start_position=(\d+)', line)
        if len(x) > 0:
            startpos.append(x[-1])

        y = re.findall('end_position=(\d+)', line)
        if len(y) > 0:
            endpos.append(y[-1])
        
        a = re.findall('html_mutation=(.*?)html_mutation_annotation', line)
        if len(a) > 0:
            mutation.append(a[-1])

        b = re.findall('html_mutation_annotation=(.*?)html_position', line)
        if len(b) > 0:
            mutationannotation.append(b[-1])
        
        c = re.findall('html_gene_name=(.*?)html_gene_product', line)
        if len(c) > 0:
            genename.append(c[-1])
        
        d = re.findall('html_gene_product=(.*?)html_mutation', line)
        if len(d) > 0:
            geneproduct.append(d[-1])

        t = re.findall('TIME\t(.*)', line)
        if len(t) > 0:
            time.append(t[-1])

        p = re.findall('POPULATION\t(.*)', line)
        if len(p) > 0:
            pop.append(p[-1])

        cl = re.findall('CLONE\t(.*)', line)
        if len(cl) > 0:
            clone.append(cl[-1])

    n = len(startpos)
    t = time[-1]
    time = list(itertools.repeat(t, n))

    p = pop[-1]
    pop = list(itertools.repeat(p, n))

    cl = clone[-1]
    clone = list(itertools.repeat(cl, n))

#writes metadata to every row it is associated with in each csv

    def WriteListToCSV(csv_file,csv_columns,rows):
        try:
            with open(csv_file, 'w') as csvfile:
                writer = csv.writer(csvfile, dialect='excel', quoting=csv.QUOTE_NONNUMERIC)
                writer.writerow(csv_columns)
                for row in rows:
                    writer.writerow(row)
        except IOError as (errno, strerror):
                print("I/O error({0}): {1}".format(errno, strerror))    
        return              
#this except IOError as (errno, strerror): is the reason why the script must be run in Python2; syntax was changed in Python3
#and i'm not 100% sure how to change it to be compatible
    csv_columns = ['Start_Position','End_Position','Mutation','Mutation_Annotation',
               'Gene_Name', 'Gene_Product', 'Time', 'Population', 'Clone']
    rows = zip(startpos, endpos, mutation, mutationannotation, genename,
           geneproduct, time, pop, clone)

#writes all lists by column into a new csv file

    currentPath = os.getcwd()
    csv_file = currentPath + "/parsed/%s_%s.csv" % (originalgdname, 'parsed')

    WriteListToCSV(csv_file,csv_columns,rows)

    file.close()
