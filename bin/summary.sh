#!/bin/bash

## Creates various count files and phylogenetic trees
## inside directory "summary"

## Subcommands:
##
## Default performs all steps
##
## * clean
##     removes all intermediate files
##

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SCRIPT_DIR}/common.sh

#### 0. Clean up all existing results and exit

if [[ $1 == "clean" ]];
then
  echo "Deleting existing summary files in ${SUMMARY_DIR}"
  rm -r $SUMMARY_DIR
  exit 0
fi

#### 1. Copy the input GD files to the appropriate directory

mkdir -p $SUMMARY_DIR

## create a file that records versions used to generate output
cat ${SCRIPT_DIR}/../VERSION > ${SUMMARY_DIR}/VERSIONS
echo "breseq $GDTOOLS_VERSION" >> ${SUMMARY_DIR}/VERSIONS

mkdir -p $SUMMARY_DIR/Ara-1/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-1* $SUMMARY_DIR/Ara-1/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara-2/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-2* $SUMMARY_DIR/Ara-2/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara-3/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-3* $SUMMARY_DIR/Ara-3/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara-4/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-4* $SUMMARY_DIR/Ara-4/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara-5/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-5* $SUMMARY_DIR/Ara-5/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara-6/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara-6* $SUMMARY_DIR/Ara-6/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+1/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+1* $SUMMARY_DIR/Ara+1/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+2/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+2* $SUMMARY_DIR/Ara+2/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+3/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+3* $SUMMARY_DIR/Ara+3/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+4/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+4* $SUMMARY_DIR/Ara+4/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+5/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+5* $SUMMARY_DIR/Ara+5/01_breseq_initial_gd
mkdir -p $SUMMARY_DIR/Ara+6/01_breseq_initial_gd && cp $LTEE_CLONE_CURATED_DIR/Ara+6* $SUMMARY_DIR/Ara+6/01_breseq_initial_gd

mkdir -p $SUMMARY_DIR/MAE/01_breseq_initial_gd && cp $MAE_CLONE_CURATED_DIR/JEB* $SUMMARY_DIR/MAE/01_breseq_initial_gd


#### 2. Perform all calculations per-population

## Prepare new versions of all generated files
(cd $SUMMARY_DIR; batch_run.pl -p Ara "bash $SCRIPT_DIR/population.sh summary" )
(cd $SUMMARY_DIR; batch_run.pl -p MAE "bash $SCRIPT_DIR/population.sh summary" )

#### 3. Generate summary files that include info from all populations


##### Copy over all phylogenetic trees
mkdir -p $SUMMARY_DIR/LTEE_phylogenetic_trees
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cp 07_phylogeny/tree.rerooted.tre $SUMMARY_DIR/LTEE_phylogenetic_trees/#d.tre")


###### USED FOR GENOME SIZE
#### LTEE FINAL normalized+masked version (includes IS-adjacent still which are needed for genome size change)
## count
## --> LTEE264_genome_size.R
mkdir -p $SUMMARY_DIR/LTEE_all_normalized_masked_gd
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cp 05_normalized_masked_gd/* $SUMMARY_DIR/LTEE_all_normalized_masked_gd")
(cd $SUMMARY_DIR/LTEE_all_normalized_masked_gd && gdtools COUNT -b -s -o $SUMMARY_DIR/count.LTEE.masked.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

#### MAE FINAL normalized+masked version
mkdir -p $SUMMARY_DIR/MAE_all_normalized_masked_gd
(cd $SUMMARY_DIR && cp MAE/05_normalized_masked_gd/* MAE_all_normalized_masked_gd)
(cd $SUMMARY_DIR/MAE_all_normalized_masked_gd && gdtools COUNT -b -s -o $SUMMARY_DIR/count.MAE.masked.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

(cd $SUMMARY_DIR/MAE_all_normalized_masked_gd && ls *.gd)


###### USED FOR ALL OTHER ANALYSES
#### LTEE FINAL normalized+masked+no_IS_adjacent version
mkdir -p $SUMMARY_DIR/LTEE_all_normalized_masked_no_IS_adjacent_gd
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cp 06_normalized_masked_no_IS_adjacent_gd/* $SUMMARY_DIR/LTEE_all_normalized_masked_no_IS_adjacent_gd")
## count - note cannot use -s option because mutations are removed and that messes up before/within logic
(cd $SUMMARY_DIR/LTEE_all_normalized_masked_no_IS_adjacent_gd && gdtools COUNT -o $SUMMARY_DIR/count.LTEE.masked.no_IS_adjacent.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

#### MAE FINAL normalized+masked+no_IS_adjacent version
mkdir -p $SUMMARY_DIR/MAE_all_normalized_masked_no_IS_adjacent_gd
(cd $SUMMARY_DIR && cp $SUMMARY_DIR/MAE/06_normalized_masked_no_IS_adjacent_gd/* $SUMMARY_DIR/MAE_all_normalized_masked_no_IS_adjacent_gd)
(cd $SUMMARY_DIR/MAE_all_normalized_masked_no_IS_adjacent_gd && gdtools COUNT -o $SUMMARY_DIR/count.MAE.masked.no_IS_adjacent.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

##### USED FOR COVERAGE PLOTTING ACROSS THE GENOME 
### --> LTEE264_genome_coverage.R
(cd $SUMMARY_DIR && gdtools gd2cov -o gd2cov -r $REFERENCE_DIR/REL606.gbk `ls LTEE_all_normalized_masked_gd/*.gd`)

(cd $SUMMARY_DIR && Rscript $SCRIPT_DIR/LTEE264_genome_coverage.R)


##### USED FOR MUTATION SPECTRUM OVER TIME
### Generate input files
## --> LTEE264_mutational_spectrum.R
mkdir -p $SUMMARY_DIR/spectrum_counts

(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.500gen.gd \`ls *_500gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.1000gen.gd \`ls *_1000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.1500gen.gd \`ls *_1500gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.2000gen.gd \`ls *_2000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.5000gen.gd \`ls *_5000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.10000gen.gd \`ls *_10000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.15000gen.gd \`ls *_15000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.20000gen.gd \`ls *_20000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.30000gen.gd \`ls *_30000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.40000gen.gd \`ls *_40000gen*\`")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "cd 06_normalized_masked_no_IS_adjacent_gd && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.50000gen.gd \`ls *_50000gen*\`")

# Create a set without the alien clone
cp $SUMMARY_DIR/spectrum_counts/Ara-5.500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.500gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.1000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.1000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.1500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.1500gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.2000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.2000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.5000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.5000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.10000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.10000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.15000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.15000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.20000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.20000gen.gd
#here's the line that's different!
cp $SUMMARY_DIR/Ara-5/06_normalized_masked_no_IS_adjacent_gd/Ara-5_30000gen_10405.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.30000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.40000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.40000gen.gd
cp $SUMMARY_DIR/spectrum_counts/Ara-5.50000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.50000gen.gd

(cd $SUMMARY_DIR && batch_run.pl -p Ara "cp $SUMMARY_DIR/spectrum_counts/#d.500gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.500gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.1000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.500gen.gd $SUMMARY_DIR/spectrum_counts/#d.1000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.1500gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.1000gen.gd $SUMMARY_DIR/spectrum_counts/#d.1500gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.2000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.1500gen.gd $SUMMARY_DIR/spectrum_counts/#d.2000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.5000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.2000gen.gd $SUMMARY_DIR/spectrum_counts/#d.5000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.10000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.5000gen.gd $SUMMARY_DIR/spectrum_counts/#d.10000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.15000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.10000gen.gd $SUMMARY_DIR/spectrum_counts/#d.15000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.20000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.15000gen.gd $SUMMARY_DIR/spectrum_counts/#d.20000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.30000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.20000gen.gd $SUMMARY_DIR/spectrum_counts/#d.30000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.40000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.30000gen.gd $SUMMARY_DIR/spectrum_counts/#d.40000gen.gd")
(cd $SUMMARY_DIR && batch_run.pl -p Ara "gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/#d.0.to.50000gen.gd $SUMMARY_DIR/spectrum_counts/#d.0.to.40000gen.gd $SUMMARY_DIR/spectrum_counts/#d.50000gen.gd")

cp $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.500gen.gd
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.1000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.1000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.1500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.1000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.1500gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.2000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.1500gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.2000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.5000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.2000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.5000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.10000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.5000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.10000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.15000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.10000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.15000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.20000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.15000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.20000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.30000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.20000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.30000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.40000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.30000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.40000gen.gd)
(cd $SUMMARY_DIR && gdtools UNION -p -o $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.50000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.0.to.40000gen.gd $SUMMARY_DIR/spectrum_counts/Ara-5-no-alien.50000gen.gd)

(cd $SUMMARY_DIR/spectrum_counts && gdtools COUNT -r $REFERENCE_DIR/REL606.gbk -o $SUMMARY_DIR/spectrum_counts.csv `ls *.gd`)

(cd $SUMMARY_DIR && Rscript $SCRIPT_DIR/LTEE264_mutational_spectrum.R)

## Generate Oli style output files. Do last = very slow!
## Flavor: phylogeny aware and splitting between populations (-p)
(cd $SUMMARY_DIR/MAE_all_normalized_masked_no_IS_adjacent_gd &&  gdtools gd2oli -p -r $REFERENCE_DIR/REL606.gbk -o $SUMMARY_DIR/oli.MAE.masked.no_IS_adjacent.tab `ls *.gd`)
(cd $SUMMARY_DIR/LTEE_all_normalized_masked_no_IS_adjacent_gd &&  gdtools gd2oli -p -r $REFERENCE_DIR/REL606.gbk -o $SUMMARY_DIR/oli.LTEE.masked.no_IS_adjacent.tab `ls *.gd`)


### EXTRA STUFF for figuring out what the big deletions and amplifications are
#(cd output/spectrum_counts && gdtools UNION -p -o ../union_of_all.gd `ls *.0.to.50000gen.gd`)
#gdtools COUNT -r REL606.gbk -o union_of_all.count.csv union_of_all.gd

#gdtools REMOVE -o union_of_all_deletions.gd -c "type!=DEL" union_of_all.gd 
#gdtools REMOVE -o union_of_all_big_deletions.gd -c "size<200" union_of_all_deletions.gd 
#gdtools ANNOTATE -o union_of_all_big_deletions.html -r REL606.gbk union_of_all_big_deletions.gd

#gdtools REMOVE -o union_of_all_amplifications.gd -c "type!=AMP" union_of_all.gd 
#gdtools REMOVE -o union_of_all_big_amplifications.gd -c "size<1000" union_of_all_amplifications.gd 
#gdtools ANNOTATE -o union_of_all_big_amplifications.html -r REL606.gbk union_of_all_big_amplifications.gd

#(cd spectrum_counts && gdtools UNION -p -o ../union_of_all.nonmutators.gd Ara-5.0.to.50000gen.gd Ara-6.0.to.50000gen.gd Ara+2.0.to.50000gen.gd Ara+4.0.to.50000gen.gd Ara+5.0.to.50000gen.gd)
#gdtools COUNT -r REL606.gbk -o union_of_all.count.nonmutators.csv union_of_all.nonmutators.gd


