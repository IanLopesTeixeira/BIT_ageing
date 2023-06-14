#!/bin/bash


var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./fastqc_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tfastqc\tUsed for analysing the quality of fastq files" | tee -a $1
echo -e "\n\tThis function works for either 1 or multiple and you don't need to specify how many you want"
read -r -p $'\t'"What are the fastq files that are going to be analyzed? If you are going to present multiple files, make them separated by a space ( ) " files
echo -e "\tThese are the selected files: $files" >> $1
read -r -p $'\t'"How many cores do you want? If none is provided, it will be considered the default " cores

if [ -z "$cores" ];
then
    echo -e "\tNo cores were selected. The default will be used" >> $1
	core=""
else
    echo -e "\tThese are the amount of cores selected: $cores" >> $1
	core="-t "
	core+=$cores
fi

read -r -p $'\t'"In which path you want to save your output? If no path is provided, it will be saved in the path of each file " output

if [ -z "$output" ];
then
    echo -e "\tNo specific output has been provided. Files will be saved on the default folder" >> $1
	out=""
else
    mkdir -p $output
    echo -e "\tThis is the output folder selected: $output" >> $1
	out="-o "
	out+=$output
fi
    echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD fastqc fastqc $files $out $core"
	udocker -q run -v=$PWD:$PWD -w=$PWD fastqc fastqc $files $out $core