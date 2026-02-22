#!/bin/bash  
date
# Display usage if the script is not run with required options
usage() {
    echo "Usage: $0 -B <bam_file1> [-B <bam_file2> ...]"
    exit 1
}

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    usage
fi

# Initialize an array to hold BAM files
declare -a bam_files

# Parse command-line options
while getopts "B:" opt; do
    case $opt in
        B) bam_files+=("$OPTARG")  # Add each BAM file to the array
        ;;
        *) usage
        ;;
    esac
done

# Check if at least one BAM file is specified
if [ ${#bam_files[@]} -eq 0 ]; then
    echo "Error: At least one BAM file must be specified."
    usage
fi

# Load required modules
module load samtools
module load sequencetools
echo "modules loaded"

# Define paths to tools and files
src="/lisc/scratch/anthropology/Pinhasi_group/raimo/hg19/v54.1.p1_1240K_public.snp"
ref="/lisc/scratch/anthropology/Pinhasi_group/raimo/hg19/hg19.fa"
InputBam="/lisc/scratch/anthropology/Pinhasi_group/raimo/junBam"
OutputDir="/lisc/user/raimo/Software/PlinkPedMap"

cd $OutputDir 

# Process each BAM file
for bam_file in "${bam_files[@]}"; do
    sample=${bam_file:0:6}  # Extract the first 6 characters from each bam_file
    pileup_file="$OutputDir/${sample}_output.pileup"
    cleaned_pileup_file="$OutputDir/${sample}_cleaned_output.pileup"

    # Step 1: Create pileup file
    echo "samtools mpileup started"
    samtools mpileup -R -B -q30 -Q30 -f $ref $InputBam/$bam_file > $pileup_file
    echo "samtools mpileup done for $sample"

    # Step 2: Make substitutions: 's/chrXY/chr25/g', 's/chrX/chr23/g', 's/chrY/chr24/g', 's/chrM/chr26/g'
    sed 's/chrXY/chr25/g' $pileup_file | sed 's/chrX/chr23/g' | sed 's/chrY/chr24/g' | sed 's/chrM/chr26/g' > $cleaned_pileup_file
    echo "substitution done for $sample"

    # Step 3: Use PileupCaller to convert pileup to SNP data and create .bed .bim .fam
    pileupCaller --sampleNames $sample --samplePopName $sample -f $src -p $sample --randomHaploid < $cleaned_pileup_file
    echo "pileupCaller completed for $sample"

    # Load required modules 
    module load conda
    # conda activate plink
    conda activate plink2-2.00a5.12
    echo "plink2 module loaded - conversion started"
   

    # Step 4: Use plink2 to export PED and MAP files
    plink2 --bfile $OutputDir/$sample --export ped --out $OutputDir/$sample --threads 4
    echo "Conversion completed for $sample. Output files are located in $OutputDir"
done
date
