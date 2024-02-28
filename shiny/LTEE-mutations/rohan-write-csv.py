#!/usr/bin/env python

'''
rohan-write-csv.py by Rohan Maddamsetti.

This script uses python 2.7 for compatibility with Ben Good's LTEE metagenomics code.

Print a csv file of genes for downstream analysis with R.

Usage: python rohan-write-csv.py > ../results/LTEE-metagenome-mutations.csv
'''

import sys
import numpy
import parse_file
import timecourse_utils
from numpy.random import normal, choice, shuffle

import figure_utils
import stats_utils

## print csv header
print "Population,Position,Gene,Allele,Annotation,t0,tf,transit_time,fixation,final_frequency\n"

populations = parse_file.complete_nonmutator_lines + parse_file.mutator_lines

## process the mutations in each population
for population in populations:
    # calculate mutation trajectories
    # load mutations
    mutations, depth_tuple = parse_file.parse_annotated_timecourse(population)
    
    population_avg_depth_times, population_avg_depths, clone_avg_depth_times, clone_avg_depths = depth_tuple
    
    dummy_times,fmajors,fminors,haplotype_trajectories = parse_file.parse_haplotype_timecourse(population)
    state_times, state_trajectories = parse_file.parse_well_mixed_state_timecourse(population)
        
    times = mutations[0][10]
    Ms = numpy.zeros_like(times)*1.0
    fixed_Ms = numpy.zeros_like(times)*1.0
        
    for mutation_idx in xrange(0,len(mutations)):
 
        location, gene_name, allele, var_type, test_statistic, pvalue, cutoff_idx, depth_fold_change, depth_change_pvalue, times, alts, depths, clone_times, clone_alts, clone_depths = mutations[mutation_idx] 
        
        Ls = haplotype_trajectories[mutation_idx]
        state_Ls = state_trajectories[mutation_idx]
        
        good_idxs, filtered_alts, filtered_depths = timecourse_utils.mask_timepoints(times, alts, depths, var_type, cutoff_idx, depth_fold_change, depth_change_pvalue)
        
        freqs = timecourse_utils.estimate_frequencies(filtered_alts, filtered_depths)
        
        masked_times = times[good_idxs]
        masked_freqs = freqs[good_idxs]
        masked_state_Ls = state_Ls[good_idxs]
        
        t0,tf,transit_time = timecourse_utils.calculate_appearance_fixation_time_from_hmm(masked_times, masked_freqs, masked_state_Ls)

        final_frequency = freqs[-1]
        is_fixation = 0
        if final_frequency == 1:
            is_fixation = 1
        
        fields = [parse_file.get_pretty_name(population), location, gene_name, allele, var_type, t0, tf, transit_time,is_fixation,final_frequency]
        print ','.join([str(x) for x in fields])
