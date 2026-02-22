# Contact: alexandra.raimo@protonmail.com  
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.


##Report to summarize total, trimmed, endogenous and unique reads
## CreateReport1
echo 'ID ; Total Reads' > DATA_Reads.txt;
echo 'ID ; Trimmed Reads ; Percentual ' > DATA_TrimmedReads.txt;
for filename in ./Cutadaptlogs/*;
do
(echo -n ${filename:15:6}; echo -n ' ; '; grep 'Total reads processed' "${filename}";)>> DATA_Reads.txt;
(echo -n ${filename:15:6}; echo -n ' ; '; grep 'Reads with adapters' "${filename}"; )>> DATA_TrimmedReads.txt;
echo ${filename:15:6}
done
(sed 's/Total reads processed:/ /' DATA_Reads.txt) > DATA_Reads2;
(sed 's/Reads with adapters:/ /' DATA_TrimmedReads.txt) > DATA_TrimmedReads21;
(sed 's/,//g' DATA_Reads2) > DATA_Reads.txt;
(sed 's/(/; /' DATA_TrimmedReads21) > DATA_TrimmedReads22;
(sed 's/)//' DATA_TrimmedReads22) > DATA_TrimmedReads23;
(sed 's/%//' DATA_TrimmedReads23) > DATA_TrimmedReads24;
(sed 's/,//g' DATA_TrimmedReads24) > DATA_TrimmedReads25;
(sed 's/\./,/' DATA_TrimmedReads25) > DATA_TrimmedReads.txt;
rm DATA_Reads2;
rm DATA_TrimmedReads2*;
mv DATA_Reads.txt ./DATAnew;
mv DATA_TrimmedReads.txt ./DATAnew;