##Set our version
LTEE_ECOLI_VERSION="1"

##Check gdtools version

## For database VERSION 1
## * GD files are compatible with breseq v0.28.0+
##   BUT NOTE: stricted checking in v0.28.1 makes
##   these files fail gdtools VALID and APPLY

##Function from http://stackoverflow.com/questions/17129050
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}


GDTOOLS_VERSION_REQUIRED="0.28.0"

#capture and strip beginning text
GDTOOLS_VERSION="$(gdtools --version)"
GDTOOLS_VERSION=${GDTOOLS_VERSION#gdtools }

vercomp $GDTOOLS_VERSION $GDTOOLS_VERSION_REQUIRED

##this return value implies that $GDTOOLS_VERSION < $GDTOOLS_VERSION_REQUIRED
if [[ $? == 2 ]];
then
  echo "The GenomeDiff files in this version of the LTEE-Ecoli database"
  echo "must be used with breseq/gdtools version ${GDTOOLS_VERSION_REQUIRED}."
  echo "Your system returns version: ${GDTOOLS_VERSION}"
  exit
fi


## Set up common paths

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BATCH_RUN="perl ${SCRIPT_DIR}/batch_run.pl"
TREE_UTILS="perl ${SCRIPT_DIR}/tree_utils.pl"
REFERENCE_DIR="$SCRIPT_DIR/../reference"
SUMMARY_DIR="$SCRIPT_DIR/../summary"

LTEE_CLONE_CURATED_DIR="$SCRIPT_DIR/../LTEE-clone-curated"
MAE_CLONE_CURATED_DIR="$SCRIPT_DIR/../MAE-clone-curated"

