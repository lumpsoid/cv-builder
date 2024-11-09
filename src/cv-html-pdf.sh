#!/bin/bash

set -euo pipefail

###
## Variables
#

cvDir="/home/qq/Documents/projects/cv"

cvBuildDir="$cvDir/build"
cvSrc="$cvDir/src"
cvOutput="$cvDir/outputs"
cvContentDir="$cvDir/content"

# Name of the CV file
name=$1
dateNow=$(date +%Y-%m-%d)
cvName="$name - CV - $dateNow"
coverName="$name - Cover Letter - $dateNow"
refName="$name - References - $dateNow"

# List of sections
sections=(
  "description"
  "education"
  "experience-it"
  "articles"
  "skills"
)
# cv.md alvays at the top

mkdir -p "$cvOutput"
mkdir -p "$cvBuildDir"

rm -f "$cvBuildDir"/*.html

###
## Functions
#

convert_md_to_html() {
  local md_file="$1"

  local base_name
  base_name="$(basename "${md_file%.md}")"
  local html_file="$cvBuildDir/$base_name.html"

  if [[ -f "$md_file" ]]; then
    pandoc --section-divs -f markdown -t html5 -o "$html_file" "$md_file"
  else
    echo "Error: File $md_file does not exist."
    exit 1
  fi
}

join_html_files() {
  local output_file="$1"
  shift
  local input_files=("$@")
  pandoc --metadata title=" " --standalone -H "$cvSrc/styles.css" --section-divs -f markdown -t html5 \
    -o "$output_file" "${input_files[@]}"
}

convert_html_to_pdf() {
  local html_file="$1"
  local pdf_file="$2"
  pandoc -H "$cvSrc/layout.tex" "$html_file" -o "$pdf_file"
}

###
## Main
#

# Create HTML files for each Markdown file
for md_file in "$cvContentDir"/*.md; do
  echo "Converting $md_file to HTML..."
  convert_md_to_html "$md_file"
done

# Join the HTML files into one HTML CV
html_files=()
html_files+=("$cvBuildDir/cv.html")
# Read sections from sections.txt
while IFS= read -r section; do
  md_files+=("$cvContentDir/$section.html")
done < "$cvContentDir/sections.txt"

echo "Joining HTML files into one HTML CV..."
join_html_files "$cvBuildDir/$cvName.html" "${html_files[@]}"

# Convert the HTML CV into PDF CV
echo "Converting HTML CV to PDF..."
convert_html_to_pdf "$cvBuildDir/$cvName.html" "$cvOutput/$cvName.pdf"

# References
echo "Processing References..."
convert_md_to_html "$cvContentDir/references.md"
convert_html_to_pdf "$cvBuildDir/references.html" "$cvOutput/$refName.pdf"

# Cover Letter
echo "Processing Cover Letter..."
convert_md_to_html "$cvContentDir/cover-letter.md"
convert_html_to_pdf "$cvBuildDir/cover-letter.html" "$cvOutput/$coverName.pdf"

echo "CV generation complete."
