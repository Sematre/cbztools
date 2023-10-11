#!/bin/bash
###
### Unpacks a cbz file and converts the images into a pdf.
### Pages will be oriented automatically.
###
### Usage:
###   cbz2pdf <input> <output>
###
### Options:
###   <input>    Input cbz file with images.
###   <output>   Output pdf
###   -h, --help Show this message.

# Exit on error
set -euo pipefail

if [[ $# -ne 2 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    sed -rn 's/^### ?//;T;p' "$0"
    exit 1
fi

ANSI_RESET="\033[0m"
ANSI_BRIGHT_BLACK="\033[90m"

WORK_DIR="$(mktemp --directory -t cbz2pdf_XXXXXX)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

echo -e "${ANSI_BRIGHT_BLACK}(Step 1/2)${ANSI_RESET} Unpacking images..."
unzip "$1" -d "${WORK_DIR}"

echo -e "${ANSI_BRIGHT_BLACK}(Step 2/2)${ANSI_RESET} Creating pdf..."
img2pdf "${WORK_DIR}"/* --auto-orient --output "$2"
