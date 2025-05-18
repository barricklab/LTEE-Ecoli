# You must load the conda environment before calling this command
#conda activate LTEE-Ecoli

# Takes folders of photos named 24h_raw and 48h_raw in the current directory... copies them 
# into one folder named by generation, population, and medium... and compiles montages

#DATE="2025-03-26"
#GENERATON="081500"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GENERATION=$1
DATE=$2



FOLDER_NAME="${GENERATION}gen_${DATE}"

INDIVIDUAL_OUTPUT="individual/${FOLDER_NAME}"
mkdir -p $INDIVIDUAL_OUTPUT

$SCRIPT_DIR/rename_plate_photos.pl -i 24h_raw -e JPG -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_24h_bottom_#i"
$SCRIPT_DIR/rename_plate_photos.pl -i 24h_raw -e ORF -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_24h_bottom_#i"
$SCRIPT_DIR/rename_plate_photos.pl -i 24h_raw -e ORI -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_24h_bottom_#i"

$SCRIPT_DIR/rename_plate_photos.pl -i 48h_raw -e JPG -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_48h_bottom_#i"
$SCRIPT_DIR/rename_plate_photos.pl -i 48h_raw -e ORF -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_48h_bottom_#i"
$SCRIPT_DIR/rename_plate_photos.pl -i 48h_raw -e ORI -o $INDIVIDUAL_OUTPUT -s LTEE-INTERSPERSED -f "${GENERATION}gen_#s_#p_48h_bottom_#i"

COMPOSED_OUTPUT="composed/${FOLDER_NAME}"
mkdir -p $COMPOSED_OUTPUT

$SCRIPT_DIR/stitch_plate_photos.py --match MG_24h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT
$SCRIPT_DIR/stitch_plate_photos.py --match MA_24h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT
$SCRIPT_DIR/stitch_plate_photos.py --match TA_24h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT

$SCRIPT_DIR/stitch_plate_photos.py --match MG_48h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT
$SCRIPT_DIR/stitch_plate_photos.py --match MA_48h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT
$SCRIPT_DIR/stitch_plate_photos.py --match TA_48h --input $INDIVIDUAL_OUTPUT --output $COMPOSED_OUTPUT

#We need to remove the _bottom_ part or the names are too long

mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_24h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_24h.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_24h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_24h.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_24h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_24h.JPG

mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_24h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_24h_preview.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_24h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_24h_preview.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_24h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_24h_preview.JPG

mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_48h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_48h.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_48h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_48h.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_48h_bottom.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_48h.JPG

mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_48h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MG_48h_preview.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_48h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_MA_48h_preview.JPG
mv $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_48h_bottom_preview.JPG $COMPOSED_OUTPUT/${GENERATION}gen_COMBINED_TA_48h_preview.JPG