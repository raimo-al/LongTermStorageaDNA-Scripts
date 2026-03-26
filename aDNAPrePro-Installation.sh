#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
# Contact: alexandra.raimo@protonmail.com
# Project name:  aDNAPrePro
# Version: 1.3
# Date: Mar 2026
# aDNAPrePro-Installation.sh: End-to-end installation script
# ------------------------------------------------------------

echo "Installing aDNAPrePro..."
echo "Start: $(date '+%H:%M')"

# Define working directory
WorkDir="$HOME/aDNAPrePro"
mkdir -p "$WorkDir"
mkdir -p "$WorkDir/Scripts"

# Check wget
if ! command -v wget &> /dev/null; then
    echo "Error: wget not found."
    exit 1
fi

# Download repository
RepoURL="https://github.com/raimo-al/LongTermStorageaDNA/archive/refs/heads/main.zip"
echo "Downloading aDNAPrePro from GitHub..."
wget -q -O "$WorkDir/aDNAPrePro.zip" "$RepoURL"
echo "Download complete."

# Extract repository
unzip -q "$WorkDir/aDNAPrePro.zip" -d "$WorkDir"

# Detect extracted folder (GitHub creates repo-branch folder)
ExtractedDir=$(find "$WorkDir" -maxdepth 1 -type d -name "LongTermStorageaDNA-*" | head -n 1)

if [ -z "$ExtractedDir" ]; then
    echo "Error: Could not find extracted repository directory."
    ls -l "$WorkDir"
    exit 1
fi

# Detect script directory (e.g. 1aDNAPrePro)
ScriptDir=$(find "$ExtractedDir" -maxdepth 2 -type d -name "*aDNAPrePro*" | head -n 1)

if [ -z "$ScriptDir" ]; then
    echo "Error: Could not find script directory."
    ls -R "$ExtractedDir"
    exit 1
fi

# Copy ONLY prefixed scripts
cp "$ScriptDir"/aDNAPrePro*.sh "$WorkDir/Scripts/"
echo "Scripts installed in $WorkDir/Scripts."

# Cleanup
rm "$WorkDir/aDNAPrePro.zip"
rm -rf "$ExtractedDir"

cd "$WorkDir/Scripts"

# Remove prefix ONLY from Step scripts
shopt -s nullglob
for f in aDNAPrePro-Step*.sh; do
    mv -n "$f" "${f#aDNAPrePro-}"
done

# Make scripts executable
chmod 754 *.sh

# Create working directories
mkdir -p "$WorkDir/Cutadaptlogs"
mkdir -p "$WorkDir/Summaries"
mkdir -p "$WorkDir/DATAnew"

echo "Working directories created in $WorkDir."

# -------------------------
# Scratch directory setup
# -------------------------

read -p "Do you want to use a scratch directory? (y/n): " use_scratch

if [[ "$use_scratch" =~ ^[Yy]$ ]]; then
    while true; do
        read -p "Enter scratch directory path: " ScratchDir
        
        if [ ! -d "$ScratchDir" ]; then
            echo "Path does not exist."
            read -p "Try again? (y/n): " retry
            [[ "$retry" =~ ^[Nn]$ ]] && ScratchDir="$WorkDir" && break
            continue
        fi
        
        if [ ! -w "$ScratchDir" ]; then
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

# Create scratch subdirectories
mkdir -p "$ScratchDir/Step0d"
mkdir -p "$ScratchDir/Step1d"
mkdir -p "$ScratchDir/Step2d"
mkdir -p "$ScratchDir/Step3d"

echo "Scratch directories created in $ScratchDir."

echo ""
echo "Installation of aDNAPrePro is complete."
echo "Scripts location: $WorkDir/Scripts"
echo "Working directory: $WorkDir"
echo ""
echo "Next steps:"
echo "cd $WorkDir/Scripts"
echo "source aDNAPrePro-LoadModules.sh"
echo "./Step1.sh"
echo ""

echo "Optional PATH setup:"
echo "export PATH=\"$WorkDir/Scripts:\$PATH\""

echo "End: $(date '+%H:%M')"