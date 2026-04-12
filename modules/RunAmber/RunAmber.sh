#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Contact: alexandra.raimo@protonmail.com
# Project name: LongTermStorageaDNA Pipeline
# Version: 1.0
# Date: Apr 2026
##
# module: RunAmber
# Version: 1.0
# Date: Apr 2026
# RunAmber.sh this is the first of two shell scripts to run AMBER and to assess fragmentation in aDNA samples.
# RunAmber.sh specifically is a customized script, which was employed to run AMBER with multiple BAM files automatically and sequentially,
# if they are located in the same directory, using the Python software AMBER (https://doi.org/10.1093/bioinformatics/btae436)
# This means the script automatically updates the list “BamList.tsv” with each new sample name, BAM file, and path,
# representing a minor improvement that simplifies running multiple samples.
# NOTE: Through the automatic updating of BamList.tsv, the script enables the analysis of more than 6 samples at a time.
#
## The computational results of this work have been achieved using the University of Vienna`s Life Science Compute Cluster (LiSC).
## This script has been written to work on the LiSC cluster. Using this Pipeline in a different environment, you would possibly need to install some programs. 

#RunAmber.sh creates a *.txt summary file and *.pdf file with information on read quality with AMBER
# Software AMBER (https://github.com/tvandervalk/AMBER.git ; https://doi.org/10.1093/bioinformatics/btae436)
##
# Usage: 
##
# If you did not download the scripts using wget, first make the script executable:
# chmod 754 RunAmber.sh
##
# Requirements: 
# 	Input *.bam files
#NOTE: If you used aDNAPrePro to preprocess your samples, you will need specifically the bam files from dir "Step3d" the files "sorted_rmdup.bam" and "sorted.rmdup.bam.bai" 

#       Python3
#       AMBER (https://github.com/tvandervalk/AMBER)
# ------------------------------------------------------------

echo "Start: $(date '+%H:%M')"

# Load all needed modules
#I need python3, which is already installed in the software
#python -m pip install -U pysam
#python -m pip install -U matplotlib
#python -m pip install -U numpy

#Loads configuration if it exists (optional):
ScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   ## location of this script
if [[ -f "$ScriptDir/../config.sh" ]]; then
    echo "Loading configuration from config.sh"
    source "$ScriptDir/../config.sh"
else
    echo "No config file found. Using default settings."
fi

# Define paths to directories and files in $HOME subdirectories/working directories
# $HOME is always the /path/to/your/homedirectory/
# Define working directory
WorkDir="${WorkDir:-$HOME/RunAmber}"
AmberDir="$WorkDir/AmberDir"                               ## AmberDir: AMBER installation directory
OutputDir="${OutputDir:-$WorkDir/AmberDir/Results}"
mkdir -p "$OutputDir"

## Check for $ScratchDir 
if [[ -n "${ScratchDir:-}" ]]; then
    echo "Using ScratchDir: $ScratchDir"
else
    ScratchDir="$WorkDir"
    echo "No ScratchDir defined. Using WorkDir: $WorkDir"
fi

# Optional strict check (recommended)
if [[ ! -d "$ScratchDir" ]]; then
    echo "Error: ScratchDir does not exist: $ScratchDir"
    exit 1
fi

# Define paths for "$ScratchDir subdirectories
InputBam="$ScratchDir/AllBam"
BamList="$WorkDir/AmberDir/BamList.tsv"

# Define path for Amber
AMBER="${AMBER:-$WorkDir/AmberDir/AMBER.py}"

# Check if AMBER exists
if [[ ! -f "$AMBER" ]]; then
    echo "Error: AMBER.py not found at $AMBER"
    echo "Please download AMBER from:"
    echo "https://github.com/tvandervalk/AMBER"
    echo "and place AMBER.py in $WorkDir/AmberDir or set the path manually:"
    echo "AMBER=/path/to/AMBER.py ./RunAmber.sh"
    exit 1
fi

echo "Using AMBER: $AMBER"

# Create all working directories in your LongTermStorageaDNA directory.
mkdir -p "$(dirname "$BamList")"

# InputBam: all *.bam and *.bai files need to be located in $InputBam
# aDNAPrePro: If you used aDNAPrePro copy Bam files from Step3d to a subdirectory of your current $WorkDir 
if [[ ! -d "$InputBam" ]]; then
    echo "Error: InputBam directory does not exist: $InputBam"
    exit 1
fi

if ! compgen -G "$InputBam/*.bam" > /dev/null; then
    echo "Error: No *.bam files found in $InputBam: Please copy your *.bam files to $InputBam"
    exit 1
fi

if ! compgen -G "$InputBam/*.bai" > /dev/null; then
    echo "Warning: No *.bai files found in $InputBam: Please copy your *.bai files to $InputBam"
fi

bam_count=$(ls "$InputBam"/*.bam 2>/dev/null | wc -l)
echo "Found $bam_count BAM files in $InputBam"
# ------------------------------------------------------------------
## Main analysis:

# Go to the directory with BAM files
cd "$InputBam" || exit

# Loop through each BAM file in the directory
for bam_file in *.bam; do
    # Extract the sample name (first 6 characters of the file name)
    sample=${bam_file:0:6}
    
    # Write the sample name and BAM file path to BamList.tsv
    echo -e "${sample}\t${InputBam}/${bam_file}" > "$BamList"
    
    # Define the output file name
    sample_output="$OutputDir/${sample}-results"
    
    # Run AMBER.py for the current BAM file
    python3 "$AMBER" --bamfiles "$BamList" --output "$sample_output"
    
    # Check if the output file was successfully created
    if [[ -f "$sample_output"* 1> /dev/null 2>&1; then
        echo "Success: Results for sample $sample written to $sample_output"
    else
        echo "Error: Results for sample $sample not found in $sample_output"
    fi
done

echo "End:   $(date '+%H:%M')"
