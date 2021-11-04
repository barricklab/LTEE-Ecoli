# LTEE-Ecoli Curation

These scripts are used to curate new additions to this database and
rebuild associated resources.

## Curating New Data

To curate GenomeDiff files for a new clonal isolate, you'll want to use
the `population.sh` script. You should edit the `02_curate_add` and
`02_curate_remove` files to update mutation calls in the GenomeDiff
files. Theis script will output information on mutations that may be
missing due to issues such as a region with a mutation later being
deleted.

## Regenerate Summary Statistics

The `summary.sh` script will run the `population.sh` script on all
populations and generate some summary files in the `summary` folder.

## Generate an Input File for the Shiny App

The `gd_to_tsv_for_shiny.sh` script will populate the
`LTEE-clone-curated-annotated` directory with annotated GenomeDiff files
and then convert these into the data file needed by the Shiny app.
