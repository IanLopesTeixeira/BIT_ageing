#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./converter_report.log"
    > $1
fi
echo -e "\nHere we go:\n" | tee -a $1 
echo -e "\tconverter\tUsed to convert files into other formats" | tee -a $1
read -r -p $'\t'"Which file would you like to convert? " file

if [ -z "$file" ];
then
    echo -e "\tSorry, but no file was provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe file to be converted is: $file" >> $1

read -r -p $'\t'"What is the file format? " extension

if [ -z "$extension" ];
then
    echo -e "\tSorry, but no extension has been provided. The program is going to terminate" | tee -a $1
    exit
fi
echo -e "\tThe format of the file is: $extension" >> $1

read -r -p $'\t'"What format you want to convert to? " conversion

if [ -z "$conversion" ];
then
    echo -e "\tSorry but no conversion format has been provided. The program is going to terminate"
    exit
fi

echo -e "\tThe file will be converted to the following format: $conversion" >> $1

if [ "$extension" == "narrowPeak" ];
then
        if [ "$conversion" == "bed" ];
        then
                path=("bed")
        fi
elif [ "$extension" == "bed" ];
then
        if [ "$conversion" == "bb" ];
        then
                path=("bb")
        fi
elif [ "$extension" == "gtf" ];
then
        if [ "$conversion" == "bb" ];
        then
                path=("genePred" "bed12" "bed" "bb")
        fi
elif [ "$extension" == "bam" ];
then
        if [ "$conversion" == "bw" ];
        then
                path=("bw")
        fi
fi

filepre=${file[0]:0:-${#extension}}

count=0
while [ "$extension" != "$conversion" ]; do
        conv=${path[$count]}
        if [ "$extension" == "narrowPeak" ];
        then
                if [ "$conv" == "bed" ];
                then
                        echo -e "\tcut -d$'"\t"' -f1,2,3 "$filepre""$extension" > "$filepre""$conv"" >> $1
                        cut -d$'\t' -f1,2,3 "$filepre""$extension" > "$filepre""$conv"
                        echo -e "\tsort -k1,1 -k2,2n -k3,3n "$filepre""$conv" > "$filepre"sorted."$conv"" >> $1
                        sort -k1,1 -k2,2n -k3,3n "$filepre""$conv" > "$filepre"sorted."$conv"
                        filepre+="sorted."
                fi
        elif [ "$extension" == "bed" ];
        then
                if [ "$conv" == "bb" ];
                then
                        echo -e "udocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedToBigBed "$filepre""$extension" $GENOME_S "$filepre""$conv"" >> $1
                        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedToBigBed "$filepre""$extension" $GENOME_S "$filepre""$conv"
                fi
        elif [ "$extension" == "gtf" ];
        then
                if [ "$conv" == "genePred" ];
                then
                        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD dciobioinformatics gtfToGenePred "$filepre""$extension" "$filepre""$conv"" >> $1
                        udocker -q run -v=$PWD:$PWD -w=$PWD dciobioinformatics gtfToGenePred "$filepre""$extension" "$filepre""$conv"
                fi
        elif [ "$extension" == "genePred" ];
        then
                if [ "$conv" == "bed12" ];
                then
                        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD kentutils genePredToBed "$filepre""$extension" "$filepre""$conv"" >> $1
                        udocker -q run -v=$PWD:$PWD -w=$PWD kentutils genePredToBed "$filepre""$extension" "$filepre""$conv"
                fi
        elif [ "$extension" == "bed12" ];
        then
                if [ "$conv" == "bed" ];
                then
                        echo -e "\tsort -k 1,1 -k2,2n -k3,3n "$filepre""$extension" > "$filepre""sorted.""$conv"" >> $1
                        sort -k 1,1 -k2,2n -k3,3n "$filepre""$extension" > "$filepre""sorted.""$conv"
                        filepre+="sorted."
                fi
        elif [ "$extension" == "bam" ];
        then
                if [ "$conv" == "bw" ];
                then
                        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools samtools index "$filepre""$extension"" >> $1
                        udocker -q run -v=$PWD:$PWD -w=$PWD htstools samtools index "$filepre""$extension"
                        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD deeptools bamCoverage -b "$filepre""$extension" -o "$filepre""bw"" >> $1
                        udocker -q run -v=$PWD:$PWD -w=$PWD deeptools bamCoverage -b "$filepre""$extension" -o "$filepre""bw"
                fi
        fi
        extension=$conv
        count=$(($count + 1))
done