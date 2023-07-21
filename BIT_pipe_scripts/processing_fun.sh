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
echo -e "\tprocessing\tUsed for processing multiple files" | tee -a $1
echo -e "\tThis are the available options:\n\t\ts Sort the file by chromossome, start and then end position\n\t\tt Trimming the file, firstly by chosing only chromossomal values, and then removing mithocondrial chromossomal ones\n\t\tc Convert a file from the hg19 version to hg38 version\n\t\tr Select only transcript information from a transcriptome" | tee -a $1
read -r -p $'\t'"Which file you want to process? " file

if [ -z "$file" ];
then
	echo -e "\tSorry, but you haven't provided any file. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe file provided is: $file" >> $1

echo -e "\tThis are the available options:\n\t\ts Sort the file by chromossome, start and then end position\n\t\tt Trimming the file, firstly by chosing only chromossomal values, and then removing mithocondrial chromossomal ones\n\t\tc Convert a file from the hg19 version to hg38 version\n\t\tr Select only transcript information from a transcriptome"
read -r -p $'\t'"Which process you want to perform? Multiple processings can be chosen, but must be comma separated (,). " process

if [ -z "$process" ];
then
	echo -e "\tSorry, but you haven't provided any process. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe process desired is: $process" >> $1	

processes=(${process//,/ })
s=(${file//"/"/ })
se=${s[${#s[@]}-1]}
e=(${se//"."/ })
se=$(IFS=/ ; echo "${s[*]:0:$((${#s[@]}-1))}")
s=$(IFS=. ; echo "${e[*]:0:$((${#e[@]}-1))}")
filepre=$se"/"$s"."
extra=${e[${#e[@]}-1]}
for ix in ${processes[@]}; do
    if [[ "$ix" == "s" ]];
    then
        if [[ "$extra" == "bed" ]];
        then
            filepre=${file[0]:0:-${#extra}}
            echo -e "\tsort -k1,1 -k2,2n -k3,3n $filepre$extra | uniq > "$filepre"sorted."$extra >> $1
            sort -k1,1 -k2,2n -k3,3n $filepre$extra | uniq > "$filepre""sorted."$extra
            file="$filepre""sorted."$extra
            extra=$extra
            else
                echo -e "\tThe format of your file is incorrect. It should be bed. The program is going to terminate" | tee -a $1
                exit
            fi
    elif [[ "$ix" == "t" ]];
    then
        filepre=${file[0]:0:-${#extra}}
        echo -e "\tgrep -i '^chr' $filepre$extra > "$filepre""chr_trimming."$extra" >> $1
        grep -i '^chr' $filepre$extra > "$filepre""chr_trimming."$extra
        echo -e "\tgrep -v '^chrM' $filepre"chr_trimming."$extra > "$filepre""chr_trimming.chrM_removal."$extra" >> $1
        grep -v '^chrM' $filepre"chr_trimming."$extra > "$filepre""chr_trimming.chrM_removal."$extra
        file="$filepre""chr_trimming.chrM_removal."$extra
        extra=$extra
    elif [[ "$ix" == "c" ]];
    then
        s=(${file//"/"/ })
        se=${s[${#s[@]}-1]}
        e=(${se//_/ })
        se=$(IFS=/ ; echo "${s[*]:0:$((${#s[@]}-1))}")
        se+="/"
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools liftover $file hg19ToHg38.over.chain.gz $se${e[0]}.hg38.$extra "$se"unMapped_${e[0]}_hg19tohg38" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools liftOver $file hg19ToHg38.over.chain.gz $se${e[0]}.hg38.$extra "$se"unMapped_${e[0]}_hg19tohg38
        file=$se${e[0]}".hg38."$extra
        extra=$extra
    elif [[ "$ix" == "r" ]];
    then
        if [[ $extra == "gtf" ]];
        then
            filepre=${file[0]:0:-${#extra}}
            echo -e "\tawk -F'"\t"' '"\$3" ~ /transcript/ {print "\$0"}' $file > $filepre"transcripts."$extra" >> $1
            awk -F'\t' '$3 ~ /transcript/ {print $0}' $file > $filepre"transcripts."$extra
            file=$filepre"transcripts."$extra
            extra=$extra
        else
            echo -e "\tThe format of your file is incorrect. It should be gtf. The program is goint to terminate" | tee -a $1
            exit
        fi
    
    else
        echo -e "\tOption invalid or not comma separated given\n\t-p Possible processings. Multiple options can be chosen but must be comma separated (,):\n\t\ts Sort the file by chromossome, start and then end position\n\t\tt Trimming the file, firstly by chosing only chromossomal values, and then removing mithocondrial chromossomal ones\n\t\tc Convert a file from the hg19 version to hg38 version\n\t\tr Select only transcript information from a transcriptome" | tee -a $1
        exit
    fi
done