# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.


## CreateReport2
echo 'ID ; Endogenous' > DATA_Endogenous.txt;
echo 'ID ; Unique' > DATA_Unique.txt;
for filename in ./Summaries/*tsvsummary.txt;
do
(echo -n ${filename:12:6};echo -n ';';sed '7!d' "${filename}";)>> DATA_Endogenous.txt;
(echo -n ${filename:12:6};echo -n ';';sed '9!d' "${filename}";)>> DATA_Unique.txt;
echo ${filename:12:6}
done
(sed 's/mapped/ /' DATA_Endogenous.txt) > DATA_End21;
(sed 's/primary mapped/ /' DATA_Unique.txt) > DATA_Uni21;
(sed 's/\t/;/' DATA_End21) > DATA_End22;
(sed 's/\t/;/' DATA_Uni21) > DATA_Uni22;
(sed 's/;0//' DATA_End22) > DATA_Endogenous.txt;
(sed 's/;0//' DATA_Uni22) > DATA_Unique.txt;
rm DATA_End2*;
rm DATA_Uni2*;
mv DATA_Endogenous.txt ./DATAnew;
mv DATA_Unique.txt ./DATAnew;