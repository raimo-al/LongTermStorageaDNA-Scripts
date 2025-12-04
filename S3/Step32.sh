# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.

## Step32
module load samtools
cd /path/to/your/project/
for filename in ./Step3d/*q30.bam;
do
samtools sort "${filename}" -m 4G -@ 8 -o "${filename}"_sorted.bam;
echo ${filename:9:6}
done
cd Step3d
rename _q30.bam_sorted.bam _q30_sorted.bam *