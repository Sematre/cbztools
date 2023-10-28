#!/bin/bash
###
### Extracts images from an epub file and packages them into a cbz file.
###
### Usage:
###   epub2cbz <input> <output>
###
### Options:
###   <input>    Input epub file with images.
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

WORK_DIR="$(mktemp --directory -t epub2cbz_XXXXXX)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

mkdir "${WORK_DIR}/step2"

echo -e "${ANSI_BRIGHT_BLACK}(Step 1/3)${ANSI_RESET} Converting epub to pdf..."
ebook-convert "$1" "${WORK_DIR}/step1.pdf" --pdf-no-cover

echo -e "${ANSI_BRIGHT_BLACK}(Step 2/3)${ANSI_RESET} Extracting images from pdf..."
pdfimages -all "${WORK_DIR}/step1.pdf" "${WORK_DIR}/step2/page"

echo -e "${ANSI_BRIGHT_BLACK}(Step 3/3)${ANSI_RESET} Packaging cbz file..."
zip -jr0 "$2" "${WORK_DIR}/step2"/*
