#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./transcriptome_annotation_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\ttranscriptome_annotation\tUsed for annotate the transcriptome file and compare with reference annotation, using gffcompare" | tee -a $1
read -r -p $'\t'"What would be the transcriptome that you want to annotate? If given multiple transcriptomes, make them space separated ( ) " -a transcriptomes
if [ -z "$transcriptomes" ];
then
    echo -e "\tSorry, but no transcriptome has been provided. The program is going to terminate" | tee -a $1
    exit
fi
echo -e "\tThese are the transcriptome(s) provided: ${transcriptomes[@]}" >> $1

read -r -p $'\t'"What is the reference annotation that you want to use? Use the same you used for transcriptome assembly, if you used stringtie " annotation
if [ -z "$annotation" ];
then
    echo -e "\tSorry, but no annotation has been provided. The program is going to terminate" | tee -a $1
    exit
fi
echo -e "\tThese are the transcriptome(s) provided: ${transcriptomes[@]}" >> $1
for ix in ${transcriptomes[@]}; do
    s=(${ix//"/"/ })
    se=${s[${#s[@]}-1]}
    e=(${se//".gtf"/ })
    out=$(IFS=/ ; echo "${s[*]:0:$((${#s[@]}-1))}")
    out+="/"
    out+="gffcompare_annotation"
    mkdir $out
    out+="/"
    out+=$(IFS=".gtf" ; echo "${e[*]}")
    out+=".gffcompare"

    echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD gffcompare gffcompare -r $annotation -o $out $ix" >> $1
    udocker -q run -v=$PWD:$PWD -w=$PWD gffcompare gffcompare -r $annotation -o $out $ix
done