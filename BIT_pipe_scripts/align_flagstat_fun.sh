#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./align_flagstat_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\talign_flagstat\tUsed to see some statistics about the alignment using samtools flagstat" | tee -a $1
read -r -p $'\t'"Which is the file that is going to be analyzed? " file
if [ -z "$file" ];
then
    echo -e "\tSorry, but no file has been provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe chosen file is: $file" >> $1
read -r -p $'\t'"What would be the name of the output file? " out

if [ -z "$out" ];
then
    echo -e "\tSorry, but no output file has been provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe output file is: $out" >> $1

echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools samtools flagstat $file > $out" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD htstools samtools flagstat $file > $out