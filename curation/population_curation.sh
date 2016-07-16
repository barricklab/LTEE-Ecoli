###### PER-POPULATION SETUP 
## 00_header
##   Initial breseq run output
## 01_breseq_initial_gd
##   Initial breseq run output
## 02_curate_add
##   Files with the same names of mutations to add (false-negatives, resolved, split, deleted)
##   Added frequency=0.5
## 02_curate_remove
##   Files with the same names of mutations to remove (false-positives)
## 03_curated_gd
##   Files with the curated mutations subtracted and added
## 04_final_normalized_gd
##   Files that have been normalized to account for any manual changes that were not normalized
##   thay also have the UN evidence added back for counting purposes
## 05_normalized_masked_gd
##   Further masks out mutations in regions where they cannot reliably be called
## 06_normalized_masked_no_is_adjacent_gd
##   Further masks out mutations in regions where they cannot reliably be called

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BATCH_RUN="perl ${SCRIPT_DIR}/batch_run.pl"
TREE_UTILS="perl ${SCRIPT_DIR}/tree_utils.pl"
REFERENCE_DIR="$SCRIPT_DIR/../reference"

if [ "$PWD" == "$SCRIPT_DIR" ]; then
  echo "Do not run this script from the main 'curation directory'. Run it from within a specific population directory"
  exit
fi


echo $REFERENCE_DIR

## Create curate_add and curate_subtract files
## ONLY IF THEY DO NOT ALREADY EXIST
(mkdir -p 02_curate_add && cd 01_breseq_initial_gd; $BATCH_RUN -0 "if [ ! -f ../02_curate_add/#d ]; then gdtools SUBTRACT -o ../tmp_#d #d #d; gdtools NOT-EVIDENCE -o ../02_curate_add/#d ../tmp_#d; rm ../tmp_#d; fi")
(mkdir -p 02_curate_remove && cd 01_breseq_initial_gd; $BATCH_RUN -0 "if [ ! -f ../02_curate_remove/#d ]; then gdtools SUBTRACT -o ../tmp_#d #d #d; gdtools NOT-EVIDENCE -o ../02_curate_remove/#d ../tmp_#d; rm ../tmp_#d; fi")

echo $PWD

## VALIDATE check
(cd 00_header && gdtools VALIDATE -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)
(cd 01_breseq_initial_gd && gdtools VALIDATE -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)
(cd 02_curate_remove && gdtools VALIDATE -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)
(cd 02_curate_add && gdtools VALIDATE -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

## NORMALIZED and MASKED version
(mkdir -p 03_curated && cd 01_breseq_initial_gd && $BATCH_RUN -p "gd" -0 "gdtools SUBTRACT -o ../tmp1_#d #d ../02_curate_remove/#d `ls ../Anc*.gd` && gdtools UNION -o ../tmp2_#d ../02_curate_add/#d ../tmp1_#d && gdtools REHEADER -o ../03_curated/#d ../00_header/#d ../tmp2_#d && rm ../tmp*_#d")
(cd 03_curated && gdtools VALIDATE -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)



(mkdir -p 04_final_normalized_gd && cd 03_curated && $BATCH_RUN -p "gd" -0 "gdtools NORMALIZE -a -r $REFERENCE_DIR/REL606.gbk -o ../04_final_normalized_gd/#d #d")
(mkdir -p 05_normalized_masked_gd && cd 04_final_normalized_gd && $BATCH_RUN -p "gd" -0 "gdtools REMOVE -c type==CON -o ../tmp1_#d #d && gdtools SUBTRACT -o ../tmp2_#d ../tmp1_#d $REFERENCE_DIR/prophage-amplifications.gd && gdtools MASK -v -s -o ../05_normalized_masked_gd/#d ../tmp2_#d $REFERENCE_DIR/REL606.L20.G15.P0.M35.mask.gd && rm ../tmp*_#d")
(mkdir -p 06_normalized_masked_no_IS_adjacent_gd && cd 05_normalized_masked_gd &&  $BATCH_RUN -p "gd" -0 "gdtools REMOVE -c adjacent!=UNDEFINED -o ../06_normalized_masked_no_IS_adjacent_gd/#d #d")


### APPLY check
(mkdir -p mutated_genomes && cd 04_final_normalized_gd && $BATCH_RUN -p "gd" -0 "gdtools APPLY -r $REFERENCE_DIR/REL606.gbk -f GFF3 -o ../mutated_genomes/#e.gff #d")

##PHYLOGENY CHECK (based on final_normalized)
(mkdir -p 06_phylogeny && cd 05_normalized_masked_gd; gdtools PHYLOGENY -p -a -o ../06_phylogeny/tree -r $REFERENCE_DIR/REL606.gbk `ls ../Anc*.gd` `ls *.gd`)
$TREE_UTILS ROOT-ANCESTOR -i 06_phylogeny/tree.tre -o 06_phylogeny/tree.rerooted.tre
(rm -r 06_phylogeny/discrepancies; mkdir -p 06_phylogeny/discrepancies; $TREE_UTILS DISCREPANCIES -i 06_phylogeny/tree.rerooted.tre -p 06_phylogeny/tree.phylip -o 06_phylogeny/discrepancies/tree)


## COMPARE
(cd 04_final_normalized_gd && gdtools COMPARE -p -r $REFERENCE_DIR/REL606.gbk -o ../compare_normalized.html `ls *.gd`)
(cd 05_normalized_masked_gd && gdtools COMPARE -p -r $REFERENCE_DIR/REL606.gbk -o ../compare_normalized_masked.html `ls *.gd`)



## COUNT
(cd 01_breseq_initial_gd && gdtools COUNT -o ../initial.count.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)
(cd 05_normalized_masked_gd && gdtools COUNT -o ../final_masked.count.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)
(cd 04_final_normalized_gd && gdtools COUNT -o ../final.count.csv -r $REFERENCE_DIR/REL606.gbk `ls *.gd`)

## Oli
(cd 06_normalized_masked_no_IS_adjacent_gd &&  gdtools GD2OLI -p -r $REFERENCE_DIR/REL606.gbk -o ../oli.final_masked.no_IS_adjacent.tab `ls *.gd`)

################### Special for certain populations

### Based on SNPs only
# mkdir 07_SNP_phylogeny
# (cd 04_final_normalized_gd &&  batch_run.pl -p "gd" -0 "gdtools REMOVE -c type!=SNP -o ../07_filtered_to_SNPs/#d #d")
# (cd 07_filtered_to_SNPs; gdtools PHYLOGENY -o ../07_SNP_phylogeny/tree -r ../REL606.gbk `ls ../Anc*.gd` `ls *.gd`)
# tree_utils ROOT-ANCESTOR -i 07_SNP_phylogeny/tree.tre -o 07_SNP_phylogeny/tree.rerooted.tre

###special for Ara-2
#(cd 05_normalized_masked_gd && gdtools COMPARE -r ../REL606.gbk -o ../S.compare_normalized_masked.html Ara-2_5000gen_2180B.gd Ara-2_15000gen_7178A.gd Ara-2_20000gen_20K-S1.gd Ara-2_30000gen_30K-S1.gd Ara-2_40000gen_11036.gd Ara-2_50000gen_11335.gd)
#(cd 05_normalized_masked_gd; gdtools PHYLOGENY -o ../06_phylogeny/S.tree -r ../REL606.gbk `ls ../Anc*.gd` Ara-2_5000gen_2180B.gd Ara-2_15000gen_7178A.gd Ara-2_20000gen_20K-S1.gd Ara-2_30000gen_30K-S1.gd Ara-2_40000gen_11036.gd Ara-2_50000gen_11335.gd)
#tree_utils ROOT-ANCESTOR -i 06_phylogeny/S.tree.tre -o 06_phylogeny/S.tree.rerooted.tre

#(cd 05_normalized_masked_gd && gdtools COMPARE -r ../REL606.gbk -o ../L.compare_normalized_masked.html Ara-2_5000gen_2180A.gd Ara-2_10000gen_4537A.gd Ara-2_10000gen_4537B.gd Ara-2_15000gen_7178B.gd Ara-2_20000gen_20K-LA.gd Ara-2_30000gen_30K-L1.gd Ara-2_40000gen_11035.gd Ara-2_50000gen_11333.gd)
#(cd 05_normalized_masked_gd; gdtools PHYLOGENY -o ../06_phylogeny/L.tree -r ../REL606.gbk `ls ../Anc*.gd` Ara-2_5000gen_2180A.gd Ara-2_10000gen_4537A.gd Ara-2_10000gen_4537B.gd Ara-2_15000gen_7178B.gd Ara-2_20000gen_20K-LA.gd Ara-2_30000gen_30K-L1.gd Ara-2_40000gen_11035.gd Ara-2_50000gen_11333.gd)
#tree_utils ROOT-ANCESTOR -i 06_phylogeny/L.tree.tre -o 06_phylogeny/L.tree.rerooted.tre

###special for Ara-5, leaves out alien clone
#(cd 05_normalized_masked_gd && gdtools COMPARE -r ../REL606.gbk -o ../no_alien.compare_normalized_masked.html Ara-5_10000gen_4540A.gd Ara-5_10000gen_4540B.gd Ara-5_1000gen_968A.gd Ara-5_1000gen_968B.gd Ara-5_15000gen_7181A.gd Ara-5_15000gen_7181B.gd Ara-5_1500gen_1072A.gd Ara-5_1500gen_1072B.gd Ara-5_20000gen_8597A.gd Ara-5_20000gen_8597B.gd Ara-5_2000gen_1168A.gd Ara-5_2000gen_1168B.gd Ara-5_30000gen_10405.gd Ara-5_40000gen_10947.gd Ara-5_40000gen_10948.gd Ara-5_50000gen_11339.gd Ara-5_50000gen_11340.gd Ara-5_5000gen_2183A.gd Ara-5_5000gen_2183B.gd Ara-5_500gen_766A.gd Ara-5_500gen_766B.gd)

