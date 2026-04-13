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

# MeanFrag.sh: This is a script specifically developed for the "The effect of long-term storage on ancient DNA samples" project (unpublished).
## MeanFrag.sh calculates mean fragment length from AMBER output.
## # (READ_LENGTH / READ_COUNTS) using a weighted mean.

# NOTE:
## Input directories and parameters are provided directly via the command line when running the script
#
# Also: for the "The effect of long-term storage on ancient DNA samples" project the mean fragment length was compared between samples from
# different sequencing platforms being: the 2015 (MiSeq) and 2023 (Nova, Next Seq).
##
# Usage: 
# 
# e.g. for computing mean fragment length for one dataset:
# ./MeanFrag.sh -i1 <Path/to/InputDir1> -c1 {st|N} -o <Path/to/OutputFile>

## e.g. for computing mean fragment length for two dataset:
# ./MeanFrag.sh -i1 <Path/to/InputDir1> -c1 {st|N} -i2 <Path/to/InputDir2> -c2 {st|N} -o <Path/to/OutputFile>
#
# -o <Path/to/OutputFile> means for example ./Results/mean_fragment_length.txt
#
#   -i1   Input directory for dataset 1 (AMBER output)
#   -i2   Input directory for dataset 2 (optional)
#   -c1   Cutoff value for dataset 1 (Value 
#   -c2   Cutoff for dataset 2 (optional)
#   -o    Output file (e.g.: mean_fragment_length.txt)
#
#   st    standard: computes mean fragment length using all reads
#   N     numeric cutoff (e.g. 75): includes only reads = N bp: e.g. "-c1 90" truncates reads to 90bp
#
# The mean fragment lenghth can be computed for max 2 datasets at a time: i1, i2
#
#
# Note (project specific):
# A cutoff of 75 bp enables direct comparison between:
# - 2015 MiSeq data (max 75 bp)
# - 2023 NextSeq/NovaSeq data
#
# Example for LongTermStorageaDNA project:
# ./MeanFrag.sh -i1 ./AMBER_2015 -c1 st -i2 ./AMBER_2023 -c2 75 -o mean_fragment_length_summary.txt
# ------------------------------------------------------------

echo "Start: $(date '+%H:%M')"

# Define paths to directories and files in $HOME subdirectories/working directories
# $HOME is always the /path/to/your/homedirectory/
# Defining working directory:
WorkDir="${WorkDir:-$HOME/RunAmber}"

# Customise arguments:
InputDir1=""
InputDir2=""
CutOff1=""
CutOff2=""
OutputFile="$WorkDir/mean_fragment_length.txt"

while [[ $# -gt 0 ]]; do
    case $1 in
        -i1) InputDir1="$2"; shift ;;
        -i2) InputDir2="$2"; shift ;;
        -c1) CutOff1="$2"; shift ;;
        -c2) CutOff2="$2"; shift ;;
        -o)  OutputFile="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Check InputDir and CutOff1
if [[ -z "$InputDir1" || -z "$CutOff1" ]]; then
    echo "Error -i1 and -c1 are required: Please define these arguments"
    exit 1
fi

validate_cutoff () {
    local cutoff="$1"
    if [[ "$cutoff" != "st" && ! "$cutoff" =~ ^[0-9]+$ ]]; then
        echo "Error: cutoff must be 'st' (to include all bp lengths) or a positive number (max 100)"
        exit 1
    fi
}

validate_cutoff "$CutOff1"
if [[ -n "$CutOff2" ]]; then
    validate_cutoff "$CutOff2"
fi

# Define OutputFile
mkdir -p "$(dirname "$OutputFile")"
echo -e "Sample\tDataset\tCutoff\tMeanFragmentLength" > "$OutputFile"

# Compute weighted mean:
compute_mean () {
    local file="$1"
    local cutoff="$2"

    if [[ "$cutoff" == "st" ]]; then
        awk '
        NR>1 { sum += $1 * $2; count += $2 }
        END { if (count>0) print sum/count; else print "NA" }
        ' "$file"
    else
        awk -v max="$cutoff" '
        NR>1 && $1 <= max {
            sum += $1 * $2;
            count += $2
        }
        END {
            if (count>0) print sum/count;
            else print "NA"
        }
        ' "$file"
    fi
}

# process function:
process_dir () {
    local dir="$1"
    local cutoff="$2"
    local label="$3"

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory not found: $dir"
        exit 1
    fi

    if ! compgen -G "$dir/*.txt" > /dev/null; then
        echo "Error: No .txt files found in $dir"
        exit 1
    fi

    for file in "$dir"/*.txt; do
        sample=$(basename "$file" .txt)

        mean=$(compute_mean "$file" "$cutoff")

        echo -e "$sample\t$label\t$cutoff\t$mean" >> "$OutputFile"
    done
}

# final analysis:
process_dir "$InputDir1" "$CutOff1" "dataset1"

if [[ -n "$InputDir2" ]]; then
    process_dir "$InputDir2" "$CutOff2" "dataset2"
fi

echo "End:   $(date '+%H:%M')"
echo "Done. Output written to: $OutputFile"

