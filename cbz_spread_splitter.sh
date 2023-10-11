#!/bin/bash
###
### Splits landscape images right-to-left.
###
### Usage:
###   cbz_spread_splitter <input> <output>
###
### Options:
###   <input>    Input cbz file
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

WORK_DIR="$(mktemp --directory -t cbz_spread_splitter_XXXXXX)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

echo -e "${ANSI_BRIGHT_BLACK}(Step 1/3)${ANSI_RESET} Unpacking images..."
unzip "$1" -d "${WORK_DIR}"

echo -e "${ANSI_BRIGHT_BLACK}(Step 2/3)${ANSI_RESET} Searching for spreads..."
for filepath in "${WORK_DIR}"/*; do
	img_w="$(identify -format '%w' "${filepath}")"
	img_h="$(identify -format '%h' "${filepath}")"
	if (( img_w > img_h )); then
		echo "${filepath}: ${img_w}x${img_h}px"
		convert "${filepath}" -crop 50%x100% -reverse "$(dirname "${filepath}")/$(basename "${filepath}" .jpg)-%d.jpg"
		rm -- "${filepath}"
	fi
done

echo -e "${ANSI_BRIGHT_BLACK}(Step 3/3)${ANSI_RESET} Packaging cbz file..."
zip -jr0 "$2" "${WORK_DIR}"/*
