#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
# Contact: alexandra.raimo@protonmail.com
# Project name:  LongTermStorageaDNA Pipeline
# Version: 1.0
# Date: Apr 2026
# LongTermStorage-Installation.sh is the first script of the LongTermStorageaDNA Pipeline
# This script is optional; it sets up the environment required for the remaining scripts. 
#
## The computational results of this work have been achieved using the University of Vienna`s Life Science Compute Cluster (LiSC).
## This script has been written to work on the LiSC cluster. Using this Pipeline in a different environment, you would possibly need to install some programs. 

# LongTermStorageaDNA-Installation.sh: Installation script to run the LongTermStorageaDNA pipeline.
# ------------------------------------------------------------

echo "Installing LongTermStorageaDNA pipeline..."
echo "Start: $(date '+%H:%M')"

# $HOME is always the /path/to/your/homedirectory/
# Set up your working directory LongTermStorageaDNA
WorkDir="$HOME/LongTermStorageaDNA"
mkdir -p "$WorkDir"
mkdir -p "$WorkDir/AmberDir"
mkdir -p "$WorkDir/Scripts"

# Check wget
if ! command -v wget &> /dev/null; then
    echo "Error: wget not found."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Error: unzip not found."
    exit 1
fi

# Download repository
RepoURL="https://github.com/raimo-al/LongTermStorageaDNA/archive/refs/heads/main.zip"
echo "Downloading LongTermStorageaDNA from GitHub..."
wget -q -O "$WorkDir/LongTermStorageaDNA.zip" "$RepoURL"
echo "Download complete."

# Extract repository
unzip -q "$WorkDir/LongTermStorageaDNA.zip" -d "$WorkDir"

# Detect extracted folder
ExtractedDir=$(find "$WorkDir" -maxdepth 1 -type d -name "LongTermStorageaDNA-*" | head -n 1)

if [[ -z "$ExtractedDir" ]]; then
    echo "Error: Could not find extracted repository directory."
    exit 1
fi

# Detect script directory
ScriptDir="$ExtractedDir/modules/RunAmber"

if [[ ! -d "$ScriptDir" ]]; then
    echo "Error: RunAmber module not found in modules/RunAmber"
    exit 1
fi

unzip -q "$WorkDir/LongTermStorageaDNA.zip" -d "$WorkDir"

# Detect extracted folder
ExtractedDir=$(find "$WorkDir" -maxdepth 1 -type d -name "LongTermStorageaDNA-*" | head -n 1)

if [[ -z "$ExtractedDir" ]]; then
    echo "Error: Could not find extracted repository directory."
    exit 1
fi

# Detect script directory
ScriptDir=$(find "$ExtractedDir" -maxdepth 2 -type f -name "RunAmber.sh" -exec dirname {} \; | head -n 1)

if [[ -z "$ScriptDir" ]]; then
    echo "Error: Could not find script directory."
    exit 1
fi

#Script directory
cp "$ScriptDir"/*.sh "$WorkDir/Scripts/"
echo "Scripts installed in $WorkDir/Scripts."

# Cleanup
rm "$WorkDir/LongTermStorageaDNA.zip"
rm -rf "$ExtractedDir"

cd "$WorkDir/Scripts"

# Make scripts executable
chmod 754 *.sh
echo "All scripts in $WorkDir/Scripts made executable."

# Create all working directories:
mkdir -p "$WorkDir/AmberDir/Results"
echo "Working directories created in $WorkDir."

# Customising the scratch directory path
echo ""
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

# Create working dir dependent on ScratchDir

mkdir -p "$ScratchDir/AllBam"

# Create config file:
ConfigFile="$WorkDir/config.sh"

echo "Creating config file at $ConfigFile"

cat > "$ConfigFile" <<EOF
# LongTermStorageaDNA configuration file
WorkDir="$WorkDir"
ScratchDir="$ScratchDir"
AMBER="\$WorkDir/AmberDir/AMBER.py"
EOF

echo "Configuration saved."


echo "End: $(date '+%H:%M')"

# Option to install AMBER

echo ""
read -p "Do you want to download AMBER automatically? (y/n): " install_amber

if [[ "$install_amber" =~ ^[Yy]$ ]]; then
    git clone https://github.com/tvandervalk/AMBER.git "$WorkDir/AmberDir"
    echo "AMBER downloaded to $WorkDir/AmberDir"
else
    echo "Please download AMBER manually from:"
    echo "https://github.com/tvandervalk/AMBER"
    echo "and place AMBER.py in $WorkDir/AmberDir"
fi

echo ""
echo "Installation of LongTermStorageaDNA is complete."
echo "Scripts: $WorkDir/Scripts"
echo "ScratchDir: $ScratchDir"
echo ""
echo "Next step:"
echo "cd $WorkDir/Scripts"
echo "./RunAmber.sh"

echo "End:   $(date '+%H:%M')"
