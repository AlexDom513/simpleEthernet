#!/bin/bash

# Define the source and target directories
SOURCE_DIR="./" # Current directory (adjust if needed)
TARGET_DIR="./eth_rx/eth_rx.runs/impl_1" # 3 levels above

# Define the filenames
FILE1="eth_rx.bit" # Replace with your actual file name
FILE2="eth_rx.ltx" # Replace with your actual file name

# Check if source files exist
if [[ -e "$TARGET_DIR/$FILE1" && -e "$TARGET_DIR/$FILE2" ]]; then
  # Copy the files to the target directory
  cp "$TARGET_DIR/$FILE1" "$SOURCE_DIR"
  cp "$TARGET_DIR/$FILE2" "$SOURCE_DIR"

  echo "Files copied successfully to $TARGET_DIR"
else
  echo "One or both files do not exist in $SOURCE_DIR"
fi
