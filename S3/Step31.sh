# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.

## Step31
module load samtools
# program already on Lisc server
cd /path/to/your/project/
for filename in ./Step2d/*.sam;
do samtools view -b -q30 "${filename}" > "${filename}_q30.bam";
echo ${filename:9:6}
done
cd Step2d
rename .sam_q30.bam _q30.bam *
mv *.bam ../Step3d