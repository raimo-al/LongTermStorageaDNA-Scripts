# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.

## Step33
module load samtools
cd /path/to/your/project/
for filename in ./Step3d/*q30_sorted.bam;
do
samtools rmdup -s "${filename}" "${filename}"_rmdup.bam;
echo ${filename:9:6}
done
cd Step3d
rename q30_sorted.bam_rmdup.bam q30_sorted_rmdup.bam *
samtools index -M *q30_sorted_rmdup.bam