# To be modified , so that directories are generalised

#!/bin/bash
# Author: Alexandra Raimo (this script runs plink2tkrelated created by Daniel Fernandes)
#The name PKin means PlinkKinship, it uses the Plink text format files
# plink2tkrelated.R has to be in the same directory of this script
# launch as : /lisc/user/raimo/Software/tkg-v1.sh -f /lisc/user/raimo/Software/FreqFile/1000GP3_EUR_1240K.frq -P samples.txt
# launch this script from the directory hosting the .ped , the .map and the sample.txt files
# to do: check how /lisc/user/raimo/Software/tkgwv2-master/helpers/distSimulations.R works
date
# load the needed modules. R needs data.table. Check if data.table is installed or install.packages("data.table")
module load R 
module load conda
conda activate plink
#needs plink 1.9 and doesn´t work for now with plink2

## a lot to be be improved still. 
## freqFile hardcoded in /lisc/user/raimo/Software/tkgwv2-master/scripts/plink2tkrelated.R
echo -e "\n### Starting PKin.sh ###"
echo "Current working directory: $(pwd)"

cwd=$(pwd)
scriptwd=$(dirname "$(realpath "$0")")
echo "Script directory: $scriptwd"

# Initialize variables
argList=("$@")
plink2tkrelatedArgs=()
prefixes=()
prefix_file=""
verbose=false

# Function to display help message
show_help() {
    echo "Usage: PKin.sh [options]"
    echo "Options:"
    echo "  -h, --help                   Show help"
    echo "  -f, --freqFile FILE          Set freqFile"
    echo "  -i, --ignoreThresh VALUE     Set ignoreThresh"
    echo "  -v, --verbose                Enable verbose output"
    echo "  -P, --prefixFile FILE        Specify file containing prefixes"
}

# Process arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--freqFile)
            plink2tkrelatedArgs+=("--freqFile=$2")
            shift 2
            ;;
        -i|--ignoreThresh)
            plink2tkrelatedArgs+=("--ignoreThresh=$2")
            shift 2
            ;;
        -v|--verbose)
            plink2tkrelatedArgs+=("--verbose")
            verbose=true
            shift
            ;;
        -P|--prefixFile)
            prefix_file="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Read prefixes from file if provided
if [[ -n "$prefix_file" ]]; then
    echo "Reading prefixes from file: $prefix_file"
    if [[ -f "$prefix_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            prefixes+=("$line")
        done < "$prefix_file"
    else
        echo "Error: The file $prefix_file was not found."
        exit 1
    fi
fi

# Error if no prefixes were found
if [[ ${#prefixes[@]} -eq 0 ]]; then
    echo "Error: No prefixes found in the provided file."
    exit 1
fi

# Add PED/MAP file arguments for each prefix
for prefix in "${prefixes[@]}"; do
    plink2tkrelatedArgs+=("--pedFile=${prefix}.ped" "--mapFile=${prefix}.map")
done
echo "plink2tkrelatedArgs: ${plink2tkrelatedArgs[@]}"

# Run the plink2tkrelated command with Rscript
echo -e "\nRunning plink2tkrelated with the following command:"
command="Rscript ${scriptwd}/plink2tkrelated.R ${plink2tkrelatedArgs[@]} $scriptwd"
echo "$command"
eval "$command"
date
echo -e "\n### PKin script completed ###"