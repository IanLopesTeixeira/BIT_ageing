#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./genome_indexing_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tgenome_indexing\tUsed for indexing the the genome" | tee -a $1
read -r -p $'\t'"What genome would you like to to index? Must be a fasta file " genome

if [ -z "$genome" ]
then
    echo -e "\tSorry, but you haven't provided any genome. The program is going to terminate." | tee -a $1
	exit
fi

echo -e "\tThis is the chosen genome: $genome" >> $1
read -r -p $'\t'"What annotation would you like to use? Must be a gtf file " annotation

if [ -z "$annotation" ]
then
    echo -e "\tSorry, but you haven't provided any genome annotation. The program is going to terminate." | tee -a $1
	exit
fi

echo -e "\tThis is the chosen annotation file: $annotation" >> $1
read -r -p $'\t'"Which folder would you like to save your result? " folder

if [ -z "$folder" ]
then
    echo -e "\tSorry, but you haven't provided any folder. The program is going to terminate." | tee -a $1
	exit
fi

mkdir -p $folder
echo -e "\tThis is the folder in which the output will be saved: $folder" >> $1
echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD star STAR --runThreadN 10 --runMode genomeGenerate --genomeDir $folder --genomeFastaFiles $genome --sjdbGTFfile $annotation --sjdbOverhang 100" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD star STAR --runThreadN 10 --runMode genomeGenerate --genomeDir $folder --genomeFastaFiles $genome --sjdbGTFfile $annotation --sjdbOverhang 100