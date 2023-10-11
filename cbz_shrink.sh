#!/bin/bash
###
### Shrinks the size of a cbz file by reducing the image quality to 80%.
###
### Usage:
###   cbz_shrink <input> <output>
###
### Options:
###   <input>    Input cbz file with spreads.
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

WORK_DIR="$(mktemp --directory -t cbz_shrink_XXXXXX)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

mkdir "${WORK_DIR}/step1" "${WORK_DIR}/step2"

echo -e "${ANSI_BRIGHT_BLACK}(Step 1/3)${ANSI_RESET} Unpacking images..."
unzip "$1" -d "${WORK_DIR}/step1"

echo -e "${ANSI_BRIGHT_BLACK}(Step 2/3)${ANSI_RESET} Compressing images..."
for filepath in "${WORK_DIR}/step1"/*; do
    convert "${filepath}" -quality 80% "${WORK_DIR}/step2/$(basename "${filepath}")"
done

echo -e "${ANSI_BRIGHT_BLACK}(Step 3/3)${ANSI_RESET} Packaging cbz file..."
zip -jr0 "$2" "${WORK_DIR}/step2"/*
