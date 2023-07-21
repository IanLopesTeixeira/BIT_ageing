var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./dsbome_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tdsbome\tUsed to create the DSBome" | tee -a $1

read -r -p $'\t'"What are the DSB files that are going to be used? Make them space separated ( ) " -a files

if [ -z "$files" ];
then
    echo -e "\tSorry, but no files were provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe files chosen are: ${files[@]}" >> $1

if [ "${#files[@]}" -lt "2" ];
then
    echo -e "\tSorry, but you only provided one file. The program is going to terminate since there is no need for it" | tee -a $1
    exit
fi

read -r -p $'\t'"What is the cell line of each file provided? Please make them space separated, and make them by the same order as the files provided. If two files are from the same cell line, put it as mine times as it appears " -a cells

if [ -z "$cells" ];
then
    echo -e "\tSorry, but no cell lines were provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe cell line of files are: ${cells[@]}" >> $1

if [ "${#files[@]}" != "${#cells[@]}" ];
then
    echo -e "\tSorry but the number of files and cell lines is different. The program is going to terminate."
    exit
fi

read -r -p $'\t'"What would be the file with the chromossome sizes? " chr_sizes

if [ -z "$chr_sizes" ];
then
    echo -e "\tSorry, but no file was provided. The program is going to terminate." | tee -a $1
    exit
fi

echo -e "\tThe chromossome sizes file provided is: $chr_sizes" >> $1

read -r -p $'\t'"What is the output folder to save the results? If is the current location, just input a dot (.) " output

if [ -z "$output" ];
then
    echo -e "\tSorry but no output folder was provided. The program is going to terminate."
    exit
fi

echo -e "\tThe output folder is: $output" >> $1
output+="/"
output+="DSBome_files"
mkdir -p $output

declare -A cell_cond
total=$((${#cells[@]}-1))

for ((ix=0; ix<=$total; ix++)); do
	key=${cells[$ix]}
	if [ -v cell_cond[$key] ];
	then
		cell_cond[$key]+=" $ix"
	else
		cell_cond[$key]="$ix"
	fi
	
done

map=""

for ix in "${!cell_cond[@]}";do
	
    f=""
	indexes=${cell_cond[$ix]}
	index=(${indexes// / })
	
    for xi in ${index[@]};do
		f+=${files[$xi]}
		f+=" "
	done
    echo -e "\tcat $f | sort -k1,1 -k2,2n -k3,3n >> $output/"$ix"_all_data.bed" >> $1
	cat $f | sort -k1,1 -k2,2n -k3,3n > $output/"$ix"_all_data.bed
	echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools merge -i $output/"$ix"_all_data.bed > $output/"$ix"_merged.bed" >> $1
	udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools merge -i $output/"$ix"_all_data.bed > $output/"$ix"_merged.bed
	map+=$output/"$ix"_merged.bed
	map+=" "
done

echo -e "\tcat $map | sort -k1,1 -k2,2n -k3,3n | cut -d$"'\t'" -f1,2,3 > $output/input_dsb_common.bed" >> $1
cat $map | sort -k1,1 -k2,2n -k3,3n | cut -d$'\t' -f1,2,3 > $output/input_dsb_common.bed

echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools genomecov -g $chr_sizes -i $output/input_dsb_common.bed -bga > $output/common_dsb.map.genome.tsv" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools genomecov -g $chr_sizes -i $output/input_dsb_common.bed -bga > $output/common_dsb.map.genome.tsv

echo -e "\tawk '{if (\$4 >= 2) {print \$0}}' $output/common_dsb.map.genome.tsv | cut -d\$'"\t"' -f1,2,3 > $output/common_dsb.tsv" >> $1
awk '{if ($4 >= 2) {print $0}}' $output/common_dsb.map.genome.tsv | cut -d$'\t' -f1,2,3 > $output/common_dsb.tsv

echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools merge -i $output/common_dsb.tsv > $output/common_dsb.dsbome.bed" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools merge -i $output/common_dsb.tsv > $output/common_dsb.dsbome.bed

echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $output/common_dsb.dsbome.bed -b $map -wa -wb -sorted -filenames > $output/common_dsb.dsbome.w_names.bed" >> $1
udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $output/common_dsb.dsbome.bed -b $map -wa -wb -sorted -filenames > $output/common_dsb.dsbome.w_names.bed

> "$output"/common_dsb.dsbome.counter.bed
for ix in ${map[@]};do
	echo -e "\tgrep -i $ix $output/common_dsb.dsbome.w_names.bed | wc -l " >> $1 
	total=$(grep -i $ix $output/common_dsb.dsbome.w_names.bed | wc -l )
	echo -e "$ix $total" >> $output/common_dsb.dsbome.counter.bed
done