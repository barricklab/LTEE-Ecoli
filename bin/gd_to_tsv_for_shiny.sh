#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SCRIPT_DIR}/common.sh

mkdir -p ${SCRIPT_DIR}/../LTEE-clone-curated-annotated
(cd ${SCRIPT_DIR}/../LTEE-clone-curated && batch_run.pl -0 "gdtools ANNOTATE -f GD -r $REFERENCE_DIR/REL606.gbk -o ${SCRIPT_DIR}/../LTEE-clone-curated-annotated/#d #d")

(cd ${SCRIPT_DIR}/.. && perl bin/gd_to_tsv_for_shiny.pl)
