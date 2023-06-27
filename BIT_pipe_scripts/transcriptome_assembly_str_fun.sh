#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./transcriptome_assembly_str_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\ttranscriptome_assembly_str\tUsed for transcriptome assembly, by using stringtie pipeline" | tee -a $1

read -r -p $'\t'"What are the fastq files that are going to be used for the construction of transcriptome? If you are going to present multiple files, make them separated by a space ( ). If paired-end, please put both files (_1 and _2) in the same order (ex: SRR123_1.fastq SRR123_2.fastq SRR124_1.fastq SRR124_2.fastq; or SRR123_1.fastq SRR124_1.fastq SRR123_2.fastq SRR123_2.fastq) " -a files

if [ -z "$files" ];
then
	echo -e "\tSorry, but you haven't provided any files. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe files provided are: ${files[@]}" >> $1

read -r -p $'\t'"What is the genome directory? " genome
if [ -z "$genome" ];
then
	echo -e "\tSorry, but you haven't provided any genome directory. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe genome directory provided is: $genome" >> $1

read -r -p $'\t'"What is the genome annotation? " annotation
if [ -z "$annotation" ];
then
	echo -e "\tSorry, but you haven't provided any genome annotation. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe genome annotation provided is: $annotation" >> $1

read -r -p $'\t'"Do you want to consider multimapped reads? Provide a number of how many loci a read can align to. If you want non-multimapped reads, please give 1 " multimap
if [ -z "$multimap" ];
then
	echo -e "\tSorry, but you haven't provided any multimapping information. The program is going to terminate." | tee -a $1
	exit
fi
echo -e "\tThe reads will map to $multimap loci" >> $1
multimap_opt="--outFilterMultimapNmax"
multimap_opt+=" "
multimap_opt+=$multimap

if echo ${files[0]} | grep -q "_1.fastq" ;
then
	end="paired"
	echo -e "\tThe files are paired-end" | tee -a $1
    file_1=$(printf '%s\n' "${files[@]}" | grep -E '_1\.fastq$' | tr "\n" ",")
    if [ ${file_1: -1} == "," ];
    then
    	file_1=${file_1::-1}
    fi
    file_2=$(printf '%s\n' "${files[@]}" | grep -E '_2\.fastq$' | tr "\n" ",")
    if [ ${file_2: -1} == "," ];
    then
        file_2=${file_2::-1}
    fi
    file_inp=$file_1
    file_inp+=" "
    file_inp+=$file_2
else
	end="single"
	echo -e "\tThe files are single-end" | tee -a $1
	file_inp=$files
fi

if [ "$end" == "paired" ] && [ "${#files[@]}" -gt "2" ]; 
then
	read -r -p $'\t'"Do you want a transcriptome common to all files or a transcriptome for each of them? [all, each] " multiple
elif [ "$end" == "single" ] && [ "${#files[@]}" -gt 1 ]; 
then
	read -r -p $'\t'"Do you want a transcriptome common to all files or a transcriptome for each of them? [all, each] " multiple
fi
		
if [ "$multiple" == "all" ];
then
	read -r -p $'\t'"Since you are using multiple files, in which folder would like to save the files? The folder doesn't require to be created. " folder
	if [ -z "$folder" ];
	then
		echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
		exit
	fi 
	echo -e "It will be formed a transcriptome for corresponding to all files, which will be saved in the following folder: $folder" >> $1

	mkdir $folder -p
    s=(${folder//"/"/ })
    out=${s[${#s[@]}-1]}
    star_out=$folder/star_$out
    stringtie_out=$folder/stringtie_$out

	echo -e "udocker -q run -v=\$PWD:\$PWD -w=\$PWD star STAR --runThreadN 10 --genomeDir $genome --outFileNamePrefix "$star_out"_ --outSAMtype BAM SortedByCoordinate --readFilesIn $file_inp --quantMode GeneCounts $multimap_opt --sjdbGTFfile $annotation" >> $1
    udocker -q run -v=$PWD:$PWD -w=$PWD star STAR  --runThreadN 10 --genomeDir $genome --outFileNamePrefix "$star_out"_ --outSAMtype BAM SortedByCoordinate --readFilesIn $file_inp --quantMode GeneCounts $multimap_opt --sjdbGTFfile $annotation
    echo -e "udocker -q run -v=\$PWD:\$PWD -w=\$PWD stringtie stringtie -o $stringtie_out.gtf -p 10 --rf "$star_out"_Aligned.sortedByCoord.out.bam" >> $1
    udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie -o $stringtie_out.gtf -p 10 --rf "$star_out"_Aligned.sortedByCoord.out.bam
    echo -e "grep -i  '^chr' $stringtie_out.gtf > $stringtie_out.chr_trimming.gtf" >> $1
    grep -i  '^chr' $stringtie_out.gtf > $stringtie_out.chr_trimming.gtf
    echo -e "grep -v '^chrM' $stringtie_out.chr_trimming.gtf > $stringtie_out.chr_trimming.chrM_removal.gtf" >> $1
    grep -v '^chrM' $stringtie_out.chr_trimming.gtf > $stringtie_out.chr_trimming.chrM_removal.gtf

elif [ "$multiple" == "each" ];
then
	if [ "$end" == "single" ];
    then
		echo "yes2"
        files=$file_inp
        sep="."
    else
    	files=(${file_1//,/ })
        sep="_1."
    fi

    for ix in ${files[@]}; do
    	s=(${ix//"/"/ })
    	e=(${s[${#s[@]}-1]//"$sep"/ })
    	se=$(IFS=/ ; echo "${s[*]:0:$((${#s[@]}-1))}")
    	star_out=$se/${e[0]}/star_${e[0]}
    	stringtie_out=$se/${e[0]}/stringtie_${e[0]}
                
		mkdir $se/${e[0]} -p
    	if [ "$end" == "single" ];
    	then
        	file=$ix
		else
			file=$se"/"${e[0]}"_1.fastq"
			file+=" "
			file+=$se"/"${e[0]}"_2.fastq"
		fi
		echo "Current file: $file" | tee -a $1
		
		echo -e "udocker -q run -v=\$PWD:\$PWD -w=\$PWD star STAR --runThreadN 10 --genomeDir $genome --outFileNamePrefix "$star_out"_ --outSAMtype BAM SortedByCoordinate --readFilesIn $file --quantMode GeneCounts $multimap_opt --sjdbGTFfile $annotation" >> $1
		udocker -q run -v=$PWD:$PWD -w=$PWD star STAR  --runThreadN 10 --genomeDir $genome --outFileNamePrefix "$star_out"_ --outSAMtype BAM SortedByCoordinate --readFilesIn $file --quantMode GeneCounts $multimap_opt --sjdbGTFfile $annotation
		echo -e "udocker -q run -v=\$PWD:\$PWD -w=\$PWD stringtie stringtie -o $stringtie_out.gtf -p 10 --rf "$star_out"_Aligned.sortedByCoord.out.bam" >> $1
		udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie -o $stringtie_out.gtf -p 10 --rf "$star_out"_Aligned.sortedByCoord.out.bam
		echo -e "grep -i  '^chr' $stringtie_out.gtf > $stringtie_out.chr_trimming.gtf" >> $1
		grep -i  '^chr' $stringtie_out.gtf > $stringtie_out.chr_trimming.gtf
		echo -e "grep -v '^chrM' $stringtie_out.chr_trimming.gtf > $stringtie_out.chr_trimming.chrM_removal.gtf" >> $1
		grep -v '^chrM' $stringtie_out.chr_trimming.gtf > $stringtie_out.chr_trimming.chrM_removal.gtf
    done
else
	echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
	exit
fi