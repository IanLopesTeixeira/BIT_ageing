#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./transcriptome_merge_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\ttranscriptome_merge\tUsed for merging multilple transcriptomes created with Stringtie into a single transcriptome file (GTF)" | tee -a $1

read -r -p $'\t'"Which transcriptomes you want to merge? They need to be space separated ( ) " transcriptome

transcriptomes=$(eval $transcriptome)

if [ -z "$transcriptomes" ];
then
    echo -e "\tSorry, but you haven't provided any transcriptomes. The program is going to terminate." | tee -a $1
	exit
fi

echo -e "\tThe transcriptomes provided were: $transcriptomes" >> $1

read -r -p $'\t'"Do you have a transcriptome annotation to give? [Y/n] " decision
case $decision in
	[yY]|[yY][eE][sS]|"")
		read -r -p $'\t'"Thank you. Which is the transcriptome annotation? It needs to be a GTF file " annotation_ref
		genome="-G "$annotation_ref
		echo -e "\tThe genome provided is: $annotation_ref" >> $1
		;;
	[nN]|[nN][oO])
		echo -e "\tThank you. No annotation will be used."
		genome=""
		;;
	*)
		echo -e "\tSorry, I can't understand your option. The program is going to terminate."
		exit
esac

read -r -p $'\t'"What name would you like to save your merged transcript? Please provide it with the full path " output

if [ -z $output ];
then
	echo -e "\tSorry, but no output was given. The program is going to terminate." | tee -a $1
fi

echo -e "\tThe output file name is: $output" >> $1

echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD stringtie stringtie --merge $genome -o $output $transcriptomes" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie --merge $genome -o $output $transcriptomes
