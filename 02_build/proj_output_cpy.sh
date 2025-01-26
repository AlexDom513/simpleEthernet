#!/bin/bash

# Exit on error
set -e

# Get the Vivado output directory
OUTPUT_DIR="./project_1/project_1.runs/impl_1/"

# Validate the project directory
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Directory $OUTPUT_DIR does not exist."
    exit 1
fi

# Find the .bit and .ltx files in the project directory
BITSTREAM=$(find "$OUTPUT_DIR" -type f -name "*.bit" -print -quit)
LTX_FILE=$(find "$OUTPUT_DIR" -type f -name "*.ltx" -print -quit)

# Check if the required files exist
if [ -z "$BITSTREAM" ]; then
    echo "Error: No .bit file found in $OUTPUT_DIR."
    exit 1
fi

if [ -z "$LTX_FILE" ]; then
    echo "Error: No .ltx file found in $OUTPUT_DIR."
    exit 1
fi

# Determine the destination directory (one level up from the project directory)
DEST_DIR="./"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy the files
cp "$BITSTREAM" "$DEST_DIR"
cp "$LTX_FILE" "$DEST_DIR"

# Confirm success
echo "Copied .bit and .ltx files to $DEST_DIR."
