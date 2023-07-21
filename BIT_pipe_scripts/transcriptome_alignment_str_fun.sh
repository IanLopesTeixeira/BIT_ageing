#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./transcriptome_alignment_str_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\ttranscriptome_alignment_str\tUsed to get transcript abundance from each RNAseq alignment file to a transcriptome, using stringtie" | tee -a $1

read -r -p $'\t'"Which alignments you want to use? If given multiple files, make them space separated ( ) " file

files=($(eval $file))

if [ -z "$files" ];
then
    echo -e "\tSorry, but you haven't provided any files. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe files provided are: ${files[@]}" >> $1

read -r -p $'\t'"What is the transcriptome you want to align the files to? " transcriptome

if [ -z "$transcriptome" ];
then
    echo -e "\tSorry, but you haven't provided any transcriptome. The program is going to terminate." | tee -a $1
	exit
fi

echo -e "\tThe transcriptome provided is: $transcriptome" >> $1

for file in ${files[@]};do
        s_f=(${file//"/"/ })
        se_f=${s_f[${#s_f[@]}-2]}
        out_f=$(IFS=/ ; echo "${s_f[*]:0:$((${#s_f[@]}-1))}")
        t_f=(${transcriptome//"/"/ })
        out_t=$(IFS=/ ; echo "${t_f[*]:0:$((${#t_f[@]}-1))}")
        if [ "$out_f" == "$out_t" ];
        then
                out=$out_f"/cov_"$se_f
        else
                mkdir $out_t"/"$se_f -p
                out=$out_t"/"$se_f"/cov_"$se_f
        fi

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD stringtie stringtie -B -e -G $transcriptome -o $out -i $file" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie -B -e -G $transcriptome -o $out -i $file
done