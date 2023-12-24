#!/bin/bash
###
### Extracts images from an pdf and packages them into a cbz file.
###
### Usage:
###   pdf2cbz <input> <output>
###
### Options:
###   <input>    Input pdf with images.
###   <output>   Output cbz file
###   -h, --help Show this message.

# Exit on error
set -euo pipefail

if [[ $# -ne 2 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    sed -rn 's/^### ?//;T;p' "$0"
    exit 1
fi

ANSI_RESET="\033[0m"
ANSI_BRIGHT_BLACK="\033[90m"

WORK_DIR="$(mktemp --directory -t pdf2cbz_XXXXXX)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

echo -e "${ANSI_BRIGHT_BLACK}(Step 1/2)${ANSI_RESET} Extracting images from pdf..."
pdfimages -all "$1" "${WORK_DIR}/page"

echo -e "${ANSI_BRIGHT_BLACK}(Step 2/2)${ANSI_RESET} Packaging cbz file..."
zip -jr0 "$2" "${WORK_DIR}"/*
