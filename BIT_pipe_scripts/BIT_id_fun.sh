#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./BIT_id_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tBIT_id\tUsed for identification of BIT locations" | tee -a $1
read -r -p $'\t'"What transcriptomes are you going to use for the identification of BIT's? If you use more than one transcriptome, please make them space separated ( ). The transcriptome(s) must be trimmed for only transcripts. If the trimming is not perform, use the option available in the main script for trimming (processing) " -a transcriptomes

if [ -z "$transcriptomes" ];
then
    echo -e "\tSorry, but no files were provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe transcriptome(s) provided are: ${transcriptomes[@]}" >> $1

read -r -p $'\t'"What will be your DSBome? It can be used a DSB file instead of a originated DSBome. The file must be in a bed format, sorted " DSBome

if [ -z "$DSBome" ];
then
    echo -e "\tSorry, but no file was provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe DSB/DSBome provided is: $DSBome" >> $1

read -r -p $'\t'"What would be the file with the chromossome sizes? " chr_sizes

if [ -z "$chr_sizes" ];
then
    echo -e "\tSorry, but no file was provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe chromossome sizes file provided is: $chr_sizes" >> $1

read -r -p $'\t'"To look for BIT's there are two models available: Hotspot, in which the technique for identification of DSB has a low resolution, leading to only identifying regions with hotspots of DSB's (meaning it has a bigger size than 100 bp), so the BIT will correspond to TSS that are inserted in such hotspot regions; Upstream, in which the resolution is high enough to identify single DSB's, meaning that BIT will correspond to TSS that are downstream of the promoter by 42 nt utmost (RNA pol II footprint). [HOTSPOT/UPSTREAM] " model

if [ -z "$model" ] || [ $model != "HOTSPOT" ] && [ $model != "UPSTREAM" ];
then
    echo -e "\tSorry, but no option was provided or properly written. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe method for the analysis will be $model" >> $1

read -r -p $'\t'"What would be the prefixes for the output file? " prefix
if [ -z "$prefix" ];
then
    echo -e "\tSorry, but no prefix was provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe prefix provided is: $prefix" >> $1

for ix in ${transcriptomes[@]}; do
	echo -e "\tTranscriptome $ix" | tee -a $1
    s=(${ix//"."/ })
    se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
    form=${s[$((${#s[@]}-1))]}
    e=(${ix//"/"/ })
    out=$(IFS=/ ; echo "${e[*]:0:$((${#e[@]}-1))}")
    if [ $model == "UPSTREAM" ];
    then
        out+="/intersection_upstream"
        mkdir $out
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools flank -i $ix -g $chr_sizes -s -l 42 -r 0 > ."$se".42_up."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools flank -i $ix -g $chr_sizes -s -l 42 -r 0 > ."$se".42_up."$form"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a ."$se".42_up."$form" -b $DSBome -wa -u > "$out"/intersect_upstream_"$prefix"."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a ."$se".42_up."$form" -b $DSBome -wa -u > "$out"/intersect_upstream_"$prefix"."$form"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a ."$se".42_up."$form" -b $DSBome -wa -wb > "$out"/intersect_upstream_"$prefix"_w_dsb_info."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a ."$se".42_up."$form" -b $DSBome -wa -wb > "$out"/intersect_upstream_"$prefix"_w_dsb_info."$form"
    else
        out+="/intersection_hotspot"
        mkdir $out
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools flank -i $ix -g $chr_sizes -s -l 1 -r 0 > ."$se".1_up."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools flank -i $ix -g $chr_sizes -s -l 1 -r 0 > ."$se".1_up."$form"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools flank -i ."$se".1_up."$form" -g $chr_sizes -s -l 0 -r 1 > ."$se".tss."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools flank -i ."$se".1_up."$form" -g $chr_sizes -s -l 0 -r 1 > ."$se".tss."$form"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a ."$se".tss."$form" -b $DSBome -wa -u > "$out"/intersect_hotspot_"$prefix"."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a ."$se".tss."$form" -b $DSBome -wa -u > "$out"/intersect_hotspot_"$prefix"."$form"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a ."$se".tss."$form" -b $DSBome -wa -wb > "$out"/intersect_hotspot_"$prefix"_w_dsb_info."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a ."$se".tss."$form" -b $DSBome -wa -wb > "$out"/intersect_hotspot_"$prefix"_w_dsb_info."$form"
    fi
done