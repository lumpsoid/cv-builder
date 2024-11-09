#!/bin/bash

set -euo pipefail

###
## Variables
#

# Directory for CV
cvDir="/home/qq/Documents/projects/cv"

# Directory for CV Builds
cvSrc="$cvDir/src"
cvContentDir="$cvDir/content"
cvOutput="$cvDir/outputs"

# Name of the CV file
name=$1
dateNow=$(date +%Y-%m-%d)
cvName="$name - CV - $dateNow"
coverName="$name - Cover Letter - $dateNow"
refName="$name - References - $dateNow"

# Ensure build directory exists
mkdir -p "$cvOutput"

###
## Functions
#

convert_md_to_pdf() {
  local md_file="$1"
  local pdf_file="$2"
  if [[ -f "$md_file" ]]; then
    pandoc "$md_file" -o "$pdf_file" --template="$cvSrc/layout.tex"
  else
    echo "Error: File $md_file does not exist." >&2
    exit 1
  fi
}

join_md_files_and_convert_to_pdf() {
  local output_file="$1"
  shift
  local input_files=("$@")
  pandoc "${input_files[@]}" -o "$output_file" --template="$cvSrc/layout.tex"
}

###
## Main
#

# Collect the Markdown files
md_files=()
md_files+=("$cvContentDir/cv.md")
# Read sections from sections.txt
while IFS= read -r section; do
  md_files+=("$cvContentDir/$section.md")
done < "$cvContentDir/sections.txt"

# Join the Markdown files into one PDF CV
echo "Joining Markdown files and converting to PDF..."
join_md_files_and_convert_to_pdf "$cvOutput/$cvName.pdf" "${md_files[@]}"

# Convert References to PDF
echo "Processing References..."
convert_md_to_pdf "$cvContentDir/references.md" "$cvOutput/$refName.pdf"

# Convert Cover Letter to PDF
echo "Processing Cover Letter..."
convert_md_to_pdf "$cvContentDir/cover-letter.md" "$cvOutput/$coverName.pdf"

echo "CV generation complete."
