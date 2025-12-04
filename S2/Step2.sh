# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.

### Step2
ref ="/path/to/your/ReferenceGenome"
## For the Project the following Reference Genome was used: hg37: human_g1k_v37.fasta
module load bwa
# program already on Lisc server
cd /path/to/your/project/
for filename in ./Step1d/*.fastq;
"${filename}" > "${filename}.sam" 2> "${filename}.sam.log";
do bwa mem -t 8 -R '@RG\tID:YourProjectName\tSM:'${filename:9:6}'\tPL:ILLUMINA' $ref "${filename}" > "${filename}.sam" 2> "${filename}.sam.log";
echo ${filename:9:6}
done
cd Step1d
rename .fastq.sam .sam *
rename .fastq.sam.log .sam.log *
mv *.sam.log ../Step2d
mv *.sam ../Step2d