#!/bin/bash
# This script is used to build the project by rendering the template files with the provided configuration.
# It uses Python to process the YAML configuration and generate the output files.
# Usage: ./build.sh
# Ensure the script is executable by running: chmod +x build.sh

# Clear the output directory
rm -rf ../outputs/*

# Render the template files with the provided configuration
# The script uses Python to process the YAML configuration and generate the output files.
python3 render.py --vars ../configs/dev.yml --template_dir ../templates --output_dir ../outputs
