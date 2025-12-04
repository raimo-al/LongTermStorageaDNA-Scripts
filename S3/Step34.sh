# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.


## Step34
#rename path with summaries
module load samtools
cd /path/to/your/project/
for filename in ./Step3d/*sorted_rmdup.bam;
do
samtools flagstat -O tsv "${filename}" > /home/user/raimo/Summaries/"${filename:9:6}"_tsvsummary.txt;
echo ${filename:9:6}
done
