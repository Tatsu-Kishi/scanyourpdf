#!/bin/bash

# Make your PDF look scanned.
# Idea from the post in HN. Make a Gist with the command code.
# https://gist.github.com/jduckles/29a7c5b0b8f91530af5ca3c22b897e10
set -e

usage() {
  cat << EOF
Usage: $0 file.pdf

OPTIONS:
   -h     Show this message
   -o     Output File (default: document_flat.pdf)
   -c     Color
EOF
}

OUTPUT_FILE="document_flat.pdf"
COLORSPACE="-colorspace gray"

while getopts "o:h?" OPTION; do
  case $OPTION in
    o) OUTPUT_FILE=$OPTARG;;
    c) COLORSPACE=""
    h|?) usage; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))
INPUT_FILE=$1
TMP_FILE=$(mktemp "/tmp/$(date +"%Y-%m-%d_%T_XXXXXX")")

if [[ -z $1 ]]; then
  usage;
  exit 1
fi

echo "Converting to image (2-3 seconds per page)"
convert -density 300 "${INPUT_FILE}" ${COLORSPACE} -linear-stretch 3.5%x10% -blur 0x0.5 -attenuate 0.25 +noise Gaussian  -rotate 0.3 "${TMP_FILE}"

echo "Generating ${OUTPUT_FILE}"
gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -sColorConversionStrategy=LeaveColorUnchanged -dAutoFilterColorImages=true -dAutoFilterGrayImages=true -dDownsampleMonoImages=true -dDownsampleGrayImages=true -dDownsampleColorImages=true -sOutputFile="${OUTPUT_FILE}" "${TMP_FILE}"
rm "$TMP_FILE"
