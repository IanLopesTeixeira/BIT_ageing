#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./multiqc_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tmultiqc\tUsed for analysing the quality of multiple processes, namely transcriptome assembly" | tee -a $1
read -r -p $'\t'"Which folder you want me to analyze? " folder

if [ -z "folder" ]
then
    echo -e "\tSorry, but no folder has been provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe analyzed folder will be: $folder . This folder will be also used to save the output" >> $1
echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD multiqc multiqc $folder -o $folder -f" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD multiqc multiqc $folder -o $folder -f