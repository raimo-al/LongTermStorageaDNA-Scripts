# Contact: alexandra.raimo@protonmail.com

### Step1
## assuming you have a Directory in a Scratch Filesystem
cd /path/to/your/scratchdirectory/
## Step0d : the Directory Hosting your fastq.gz files
for filename in ./Step0d/*.fastq.gz;
do cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -m 30 "${filename}" > "${filename}.fastq" 2> "${filename}.log";
echo ${filename:9:6}
done
cd Step0d
rename .fastq.gz.fastq .fastq *
rename .fastq.gz.log .log *
mv *.log $HOME/Cutadaptlogs
## if the Directory Step1d doesn´t exist: create this directory
mv *.fastq ../Step1d
cd $HOME