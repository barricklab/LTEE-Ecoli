## Commands to be run for each population to
## 1) Create initial breseq output
## 2) Run on simulated reference genomes created by gdtools APPLY after curation
## 3) Check read depth coverage graphs for duplications and deletions
##
## All commands run on TACC

## 1) Create initial breseq output
POPULATION="Ara-3"
mkdir LTEE-264-${POPULATION}
cd LTEE-264-${POPULATION}
mkdir 01_Data
cp $HOME/work/src/dcamp/src/data/RS0042_LTEE_Timecourse/${POPULATION}_* 01_Data
gdtools download
gdtools RUNFILE --options "-l 200"
launcher_creator.py -n breseq_initial -e jbarrick@cm.utexas.edu -q normal -t 24:00:00 
qsub breseq_initial.sge

## 1) Copy gd and output back

## GD
(mkdir gd; cd 03_Output/; batch_run.pl "cp output/output.gd ../../gd/#d.gd")

## OUTPUT
cd 03_Output; batch_run.pl "scp -r output barricklab.org:LTEE-264-Ara-1-Initial/#d"


## Secondary method, create archive of
export DIR=LTEE-264-Ara+3-Rerun
mkdir ../$DIR
batch_run.pl "mv output ../../$DIR/#d"
cd ..
tar -czf ${DIR}.tgz $DIR

## 2) Run on simulated reference genomes created by gdtools APPLY after curation
#     Requires copy of apply directory back to lonestar for another breseq run.
#     Name it 02_Apply
gdtools RUNFILE -r apply_commands -m breseq-apply --options "-l 200"
launcher_creator.py -j apply_commands -n breseq_rerun -e jbarrick@cm.utexas.edu -q normal -t 24:00:00 
qsub breseq_rerun.sge

## 3) Check read depth coverage graphs for duplications and deletions

##    Look for large amplifications that aren't revealed by junctions (and check those that are)
##    Run on idev node

(mkdir -p coverage_graphs && cd 03_Output && batch_run.pl "breseq BAM2COV --format PDF -1 -o ../../coverage_graphs/#d -a -p 1000 -s 3.3 --tile-size 10000 --tile-overlap 2000 &")

## Final coverage check
(mkdir -p apply_coverage_graphs && cd 03_Apply_Output && batch_run.pl "breseq BAM2COV --format PDF -1 -p 2500 -o ../../apply_coverage_graphs/#d -a --tile-size 250000 --tile-overlap 125000 &")

##prophage coverage check
(mkdir -p phage_coverage && cd 03_Output && batch_run.pl "breseq BAM2COV --format PDF -1 -p 2500 -o ../../../phage_coverage/#d -a REL606:650000-1150000 &")

