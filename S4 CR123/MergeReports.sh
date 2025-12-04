# Contact: alexandra.raimo@protonmail.com
## These scripts were written to work on a cluster, when using this Pipeline outside of a cluster, some programs may Need to be installed.

## MergeData
cd DATAmerged;
cp ../DATAold/DATA_Reads.txt DATA_Reads1.txt;
cp ../DATAold/DATA_TrimmedReads.txt DATA_TrimmedReads1.txt;
cp ../DATAold/DATA_Endogenous.txt DATA_Endogenous1.txt;
cp ../DATAold/DATA_Unique.txt DATA_Unique1.txt;
cp ../DATAnew/DATA_Reads.txt DATA_Reads2.txt;
cp ../DATAnew/DATA_TrimmedReads.txt DATA_TrimmedReads2.txt;
cp ../DATAnew/DATA_Endogenous.txt DATA_Endogenous2.txt;
cp ../DATAnew/DATA_Unique.txt DATA_Unique2.txt;
sed -i '1d' DATA_Reads2.txt;
sed -i '1d' DATA_TrimmedReads2.txt;
sed -i '1d' DATA_Endogenous2.txt;
sed -i '1d' DATA_Unique2.txt;
cat DATA_Reads1.txt DATA_Reads2.txt > DATA_Reads.txt;
cat DATA_TrimmedReads1.txt DATA_TrimmedReads2.txt > DATA_TrimmedReads.txt;
cat DATA_Endogenous1.txt DATA_Endogenous2.txt > DATA_Endogenous.txt;
cat DATA_Unique1.txt DATA_Unique2.txt > DATA_Unique.txt;
rm *1.txt;
rm *2.txt;
cd .. ;
