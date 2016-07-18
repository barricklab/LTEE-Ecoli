# LTEE-Ecoli
Genomics resources for the long-term evolution experiment with *Escherichia coli*.

For related information and data, see also:
* [Lenski LTEE Project Site](http://myxo.css.msu.edu/ecoli)
* [NCBI LTEE Bioproject Site](http://www.ncbi.nlm.nih.gov/bioproject/294072)
* [Breseq Pipeline Site](https://github.com/barricklab/breseq)
* [GenomeDiff file description](http://barricklab.org/twiki/pub/Lab/ToolsBacterialGenomeResequencing/documentation/gd_format.html)

# Contents

## LTEE-clone-curated

Lists of mutations in clonal isolates from the long-term evolution experiment
in GenomeDiff format. This format is described in the *breseq* documentation.

## MAE-clone-curated

Lists of mutations in clonal isolates from the mutation accumulation evolution
experiment in GenomeDiff format. This format is described in the *breseq* documentation.

## summary

Output of mutation counts, phylogenetic trees, etc. generated from the curated GenomeDiff
files. Counts in these files reflect removing mutations in repetitive regions
(masked files) and/or mutational hotspots adjacent to IS elements (no_IS_adjacent files).

## bin

Scripts used for performing curation and generating summary output files.

