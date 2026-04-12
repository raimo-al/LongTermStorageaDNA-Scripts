#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Contact: alexandra.raimo@protonmail.com
# Project name:  LongTermStorageaDNA Pipeline
# Version: 1.1
# Date: Apr 2026
#
# module: RunAmber
# Version: 1.0
# Date: Apr 2026
# RunAmber-Installation.sh is the first script of the LongTermStorageaDNA Pipeline
# This script is optional; it sets up the environment required for the remaining scripts to Run AMBER and calculate mean fragment length. 
#
## The computational results of this work have been achieved using the University of Vienna`s Life Science Compute Cluster (LiSC).
## This script has been written to work on the LiSC cluster. Using this Pipeline in a different environment, you would possibly need to install some programs. 

# RunAmber-Installation.sh: Installation script to run AMBER and calculate mean fragment length
# AMBER requires updating the sample name and path after each sample in the textfile “BamList.tsv”.
# For this project, a customized script (see Appendix C4), was employed to run multiple BAM files automatically sequentially,
# if they were located in the same directory.
# This means this script automatically updates the list “BamList.tsv” with each new sample name, BAM-file and path.
# ------------------------------------------------------------

echo "Installing RunAmber module..."
echo "Start: $(date '+%H:%M')"

# Define working directories:

WorkDir="$HOME/RunAmber"                 ## RunAmber: your working directory
ScriptsDir="$WorkDir/Scripts"            ## Scripts: the dir hosting the scripts to Run AMBER and calculate mean fragment length
AmberDir="$WorkDir/AmberDir"             ## AmberDir: AMBER installation directory
ResultsDir="$AmberDir/Results"           ## Results: AMBER output directory hosting your AMBER results
RunAmberDir="$WorkDir"

mkdir -p "$ScriptsDir"
mkdir -p "$AmberDir"
mkdir -p "$ResultsDir"

# Check dependencies:
for cmd in wget; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd not found."
        exit 1
    fi
done

# Download RunAmber module files:
BaseURL="https://raw.githubusercontent.com/raimo-al/LongTermStorageaDNA/main/modules/RunAmber"
echo "Downloading RunAmber module from LongTermStorageaDNAPipeline..."
wget -q -O "$ScriptsDir/RunAmber.sh" "$BaseURL/RunAmber.sh"

# Optional: if you have more scripts
# wget -q -O "$ScriptsDir/helper.sh" "$BaseURL/helper.sh"

echo "Download of RunAmber module complete."

# Make scripts executable:
chmod 754 "$ScriptsDir"/*.sh
echo "All scripts made executable."

# Customising the scratch directory path

read -p "Do you want to use a scratch directory? (y/n): " use_scratch

if [[ "$use_scratch" =~ ^[Yy]$ ]]; then
    while true; do
        read -p "Enter scratch directory path: " ScratchDir

        if [[ ! -d "$ScratchDir" ]]; then
            echo "Path does not exist."
            read -p "Try again? (y/n): " retry
            [[ "$retry" =~ ^[Nn]$ ]] && ScratchDir="$WorkDir" && break
            continue
        fi

        if [[ ! -w "$ScratchDir" ]]; then
            echo "No write permission."
            read -p "Try another path? (y/n): " retry
            [[ "$retry" =~ ^[Nn]$ ]] && ScratchDir="$WorkDir" && break
            continue
        fi

        echo "Using scratch directory: $ScratchDir"
        break
    done
else
    ScratchDir="$WorkDir"
    echo "Using working directory as scratch: $ScratchDir"
fi

# AllBam: Create scratch directory
AllBamDir="$ScratchDir/AllBam" ##AllBam: the dir hosting all your *.bam and *.bai files

if [[ ! -d "$AllBamDir" ]]; then
    mkdir -p "$AllBamDir"
    echo "Directory created: $AllBamDir"
    echo "Please place all BAM (.bam) and index (.bai) files in this directory."
else
    echo "Directory already exists: $AllBamDir"
fi

# Create config file:
ConfigFile="$RunAmberDir/config.sh"
echo "Creating config file at $ConfigFile"

cat > "$ConfigFile" <<EOF
# RunAmber configuration file
WorkDir="$WorkDir"
RunAmberDir="$RunAmberDir"
ScratchDir="$ScratchDir"
AMBER="\$RunAmberDir/AmberDir/AMBER.py"
EOF

echo "Configuration saved."

# Optional AMBER installation:

if ! command -v git &> /dev/null; then
    echo "Warning: git not found. Skipping AMBER installation."
else
    echo ""
    read -p "Do you want to download AMBER automatically? (y/n): " install_amber

    if [[ "$install_amber" =~ ^[Yy]$ ]]; then
        git clone https://github.com/tvandervalk/AMBER.git "$RunAmberDir/AmberDir"
        echo "AMBER downloaded to $RunAmberDir/AmberDir"
    else
        echo "Please download AMBER manually from:"
        echo "https://github.com/tvandervalk/AMBER"
        echo "and place AMBER.py in $RunAmberDir/AmberDir"
    fi
fi

echo ""
echo "Installation complete."
echo ""
echo "Next step:"
echo "cd $ScriptsDir"

echo "End: $(date '+%H:%M')"