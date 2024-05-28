#!/bin/bash

input_file="opentelemetry-demo.yaml"  # Path to your big YAML file
output_dir="output_files"        # Directory where you want to save the split files

# Ensure the output directory exists
mkdir -p "$output_dir"

# Initialize count to 0
count=0

# Split the file and write each part to a separate file
awk -v output_dir="$output_dir" '
  BEGIN {
    count = 0
    file = output_dir "/doc_" ++count ".yaml"
  }
  /^---$/ {
    count++
    file = output_dir "/doc_" count ".yaml"
    next
  }
  {
    print > file
  }
' "$input_file"

echo "Splitting complete. Files saved in $output_dir"
