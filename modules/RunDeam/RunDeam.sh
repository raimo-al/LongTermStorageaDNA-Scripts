#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Contact: alexandra.raimo@protonmail.com
# Project name: LongTermStorageaDNA Pipeline
# Version: 1.0
# Date: Apr 2026
##
# module: RunDeam
# Version: 1.0
# Date: May 2026

# RunDeam.sh: This is the second of two script specifically developed for the "The effect of long-term storage on ancient DNA samples" project (unpublished).
# RunDeam.sh assesses terminal deamination patterns in ancient DNA samples with the programs
# mapDamage (https://doi.org/10.1093/bioinformatics/btt193) and
# SAMtools (https://github.com/samtools/samtools; https://doi.org/10.1093/gigascience/giab008)
#
# Specifically, RunDeam.sh computes using the software mapDamage and customized scripts:
#   - 5' Cytosine to Thymine (C-to-T) misincorporation (deamination) frequencies
#   - 3' Guanine to Adenine  (G-to-A) misincorporation (deamination) frequencies
#
## The computational results of this work have been achieved using the University of Vienna`s Life Science Compute Cluster (LiSC).
## This script has been written to work on the LiSC cluster. Using this Pipeline in a different environment, you would possibly need to install some programs. 
#
## NOTE: The script automatically runs mapDamage sequentially on multiple BAM files located in the same directory.
#
#RunDeam.sh creates a ...
# Software mapDamage (https://github.com/ginolhac/mapDamage ; https://doi.org/10.1093/bioinformatics/btt193; https://doi.org/10.1093/bioinformatics/btr347)
##
# Usage:
##
# If you did not download the scripts using wget, first make the script executable:
# chmod 754 RunDeam.sh
##
# Requirements: 
# 	Input:
#	*_sorted_rmdup.bam files
#	*_sorted_rmdup.bam.bai
#
# 	Reference genome:
#	*.fa files
# ------------------------------------------------------------

echo "Start: $(date '+%H:%M')"

# Load all needed modules
module load mapDamage/2.2.3-foss-2022a
#module load SAMtools/1.23-GCC-14.2.0 
module load SAMtools/1.16.1-GCC-11.3.0

# Check module availability
if ! command -v samtools &> /dev/null; then
    echo "Error: samtools not found."
    exit 1
fi

if ! command -v mapDamage &> /dev/null; then
    echo "Error: mapDamage not found."
    exit 1
fi


# Loads configuration if it exists (optional):
ScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   ## location of this script

if [[ -f "$ScriptDir/../config.sh" ]]; then
    echo "Loading configuration from config.sh"
    source "$ScriptDir/../config.sh"

# Detect reference genome
ref=$(find "$RefDir" -maxdepth 1 -name "*.fa" | head -n 1)

#Check for reference genome
if [[ -z "$ref" ]]; then
    echo "Error: No reference genome (*.fa) found in $RefDir."
    exit 1
fi

#Quality control: check so that only one ref genome is selected.
fa_count=$(find "$RefDir" -maxdepth 1 -name "*.fa" | wc -l)
if [[ "$fa_count" -gt 1 ]]; then
    echo "Error: Multiple reference genomes found in:"
    echo "$RefDir"
    echo "Please keep only one *.fa file."
    exit 1
fi

else

	echo "No config file found: Using manually defined paths Please edit manually inside RunDeam.sh your individual path for ScratchDir and ref. "

# Customising path manually if RunDeam-Installation.sh was not used for module installation.
#ScratchDir="/path/to/your/scratchdirectory/" # assuming there is a Scratch Directory in an ad hoc Filesystem: adapt to your individual path 
ScratchDir=""

#Check for path in "$ScratchDir"
if [[ -z "$ScratchDir" ]]; then
    echo 'ScratchDir="" is not defined. Please insert your path in RunDeam.sh'
    exit 1
fi

#Set the path for your reference genome: ref="/path/to/your/ReferenceGenome.fasta" ; in this script following Reference Genome was used: hg37: human_g1k_v37.fasta
ref=""

#Check for path in "$ref"
if [[ -z "$ref" ]]; then
    echo 'ref="" is not defined. Please insert your path in RunDeam.sh'
    exit 1
fi

fi


# Define paths to directories and files in $HOME subdirectories/working directories
# $HOME is always the /path/to/your/homedirectory/
# Define working directory
WorkDir="${WorkDir:-$HOME/RunDeam}"             ## RunDeam: Run Deamination installation directory                           
OutputDir="${OutputDir:-$WorkDir/Results}"      ## Results: dir hosting you results files
mkdir -p "$OutputDir"

## Check for $ScratchDir 
if [[ -n "${ScratchDir:-}" ]]; then
    echo "Using ScratchDir: $ScratchDir"
else
    ScratchDir="$WorkDir"
    echo "No ScratchDir defined. Using WorkDir: $WorkDir"
fi

if [[ ! -d "$ScratchDir" ]]; then
    echo "Error: ScratchDir does not exist: $ScratchDir"
    exit 1
fi

# Define paths for "$ScratchDir subdirectories
InputBam="$ScratchDir/AllBam"

# Validate "$InputBam" dir
if [[ ! -d "$InputBam" ]]; then
    echo "Error: InputBam directory does not exist:"
    echo ""
    echo "Please place your *.bam and *.bai files in $InputBam."
    exit 1
fi

# Check BAM files
if ! compgen -G "$InputBam/*.bam" > /dev/null; then
    echo "Error: No *.bam files found in $InputBam: Please copy your BAM files to $InputBam ."
    exit 1
fi

# Check BAI files
if ! compgen -G "$InputBam/*.bai" > /dev/null; then
    echo "Warning: No *.bai index files found in $InputBam"
fi

# Check if reference genome is defined
if [[ -z "$ref" ]]; then
    echo "Error: Reference genome path is not defined. Please check your  path: ref=\"/path/to/your/ReferenceGenome.fasta\"."
    echo ""
    echo "If you used RunDeam-Installation.sh please check $ref diretcly 1.) inside config.sh or in 2.) RunDeam.sh."
    exit 1
fi

# Warning if reference genome was not found: $ref and *.fai
if [[ ! -f "$ref" ]]; then
    echo "Error: Reference genome $ref not found:"
    exit 1
fi

if [[ ! -f "${ref}.fai" ]]; then
    echo "Warning: Reference genome $ref index .fai not found:"
fi

#----------------------------------------------------
## Main analysis: 
#Run mapDamage

cd "$InputBam" || exit

for bam_file in *_sorted_rmdup.bam; do

    # Extract sample name
    sample=$(basename "$bam_file" _sorted_rmdup.bam)

    echo ""
    echo "Processing sample: $sample"

    # Create sample output directory
    SampleOutput="$OutputDir/$sample"

    mkdir -p "$SampleOutput"

    # Create filtered BAM for mapDamage (to remove soft clipped bases)
    FilteredBam="$SampleOutput/${sample}_mapped.bam"

    samtools view \
        -b \
        -q 30 \
        -F 2308 \
        "$InputBam/$bam_file" \
        > "$FilteredBam"

    # Index filtered BAM
    samtools index "$FilteredBam"

    # Run mapDamage on filtered BAM
    mapDamage \
        -i "$FilteredBam" \
        -r "$ref" \
        -d "$SampleOutput"

    # Check output
    if [[ -f "$SampleOutput/5pCtoT_freq.txt" ]]; then
        echo "Success: mapDamage completed for $sample"
    else
        echo "Warning: mapDamage output not detected for $sample"
    fi

    echo "--------------------------------"

done

echo ""
echo "All RunDeam analyses completed, output files can be found in $OutputDir ."

echo "End: $(date '+%H:%M')"

