#!/bin/bash

characterization () {
    local s=(${1//"/"/ })
    local e=(${s[${#s[@]}-1]//"."/ })
    local out="$2""/"
    local out+=${e[0]}
    local out+="_characteristics.txt"
    > $out

    local job=(${3//,/ })

    echo -e "Characteristic\t$1" >> $out

    for i in ${job[@]};do
            if [[ "$i" == "t" ]];
            then
                    local sizes=($(awk '{print $3-$2}' $1  | sort -n | tr "\n" " "))
                    local sum=$(IFS=+; echo "$((${sizes[*]}))")
                    local avr=$(($sum/${#sizes[@]}))
                    local median=${sizes[$((${#sizes[@]}/2))]}
                    echo -e "\t\tsizes=(\$(awk '{print \$3-\$2}' $1  | sort -n | tr \""\n"\" \" \"))\n\t\tsum=\$(IFS=+; echo "\$\(\(\${sizes[*]}\)\)")\n\t\tavr=\$((\$sum\${#sizes[@]}))\n\t\tmedian=\${sizes[\$((\${#sizes[@]}/2))]}" >> $4
                    echo -e "Distances\t$(echo ${sizes[*]} | tr " " "\t")" >> $out
                    echo -e "Number of DSB\t${#sizes[@]}" >> $out
                    echo -e "Average size\t$avr" >> $out
                    echo -e "Median\t$median" >> $out
            elif [[ "$i" == "d" ]];
            then
                    local sizes=($(awk '{print $3-$2}' $1  | sort -n | tr "\n" " "))
                    echo -e "\t\tsizes=(\$(awk '{print \$3-\$2}' $1  | sort -n | tr \""\n"\" \" \"))" >> $4
                    echo -e "Distances\t${sizes[@]}" >> $out
            elif [[ "$i" == "n" ]];
            then
                    local sizes=($(awk '{print $3-$2}' $1  | sort -n | tr "\n" " "))
                    echo -e "\t\tsizes=(\$(awk '{print \$3-\$2}' $1  | sort -n | tr \""\n"\" \" \"))" >> $4
                    echo -e "Number of DSB\t${#sizes[@]}" >> $out
            elif [[ "$i" == "a" ]];
            then
                    local sizes=($(awk '{print $3-$2}' $1  | sort -n | tr "\n" " "))
                    local sum=$(IFS=+; echo "$((${sizes[*]}))")
                    local avr=$(($sum/${#sizes[@]}))
                    echo -e "\t\tsizes=(\$(awk '{print \$3-\$2}' $1 | sort -n | tr \""\n"\" \" \"))\n\t\tsum=\$(IFS=+; echo "\$\(\(\${sizes[*]}\)\)")\n\t\tavr=\$((\$sum\${#sizes[@]}))" >> $4
                    echo -e "Average size\t$avr" >> $out
            elif [[ "$i" == "m" ]];
            then
                    local sizes=($(awk '{print $3-$2}' $1  | sort -n | tr "\n" " "))
                    local median=${sizes[$((${#sizes[@]}/2))]}
                    echo -e "\t\tsizes=(\$(awk '{print \$3-\$2}' $1  | sort -n | tr \""\n"\" \" \"))\n\t\tmedian=\${sizes[\$((\${#sizes[@]}/2))]}" >> $4
                    echo -e "Median\t$median" >> $out
            else
                echo -e "Option invalid or not comma separated given\n-c Possible characterizations. Multiple options can be chosen but must be separated by a comma (,):\n\td Sorted size of DSB (hotspots) provided\n\tn Number of DSB\n\ta Average size of DSB (hotspots) provided\n\tm Median size of DSB (hotspots) provided\n\tt All the previous characterizations"
                    exit
            fi
    done
}

if [ -z $1 ];
then
    set -- "./dsb_characterization_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tdsb_characterization\tUsed for characterize DSB files" | tee -a $1
read -r -p $'\t'"Which DSB file(s) you want to characterize? If using multiple files make them space separated ( ). They must be in a bed format, sorted. If not, please convert/process them first " -a files

if [ -z "$files" ];
then
    echo -e "\tSorry, but no files were provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe files provided are: ${files[@]}" >> $1

read -r -p $'\t'"In which folder would you like to save your outputs? " output
if [ -z "$output" ];
then
    echo -e "\tSorry, but no output folder was provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe output folder is: $output" >> $1
mkdir -p $output

echo -e "\tThis are the available options:\n\t\td Sorted size of DSB (hotspots) provided\n\t\tn Number of DSB\n\t\ta Average size of DSB (hotspots) provided\n\t\tm Median size of DSB (hotspots) provided\n\t\tt All the previous characterizations" | tee -a $1
		
read -r -p $'\t'"Will you want the same characterization for all files? If not using multiple files, just say yes [Y/n]" decision
		case $decision in
			[yY]|[yY][eE][sS]|"")
				read -r -p $'\t'"Thank you. What will be your characterization? You can choose multiple options, but must be comma separated (,) [t/d/a/n/m] " job
                echo -e "\tThe job chosen for all the files was: $job" >> $1
				for ix in ${files[@]}; do
                    characterization $ix $output $job $1
				done
				;;
			[nN]|[nN][oO])
				for ix in ${files[@]}; do
					echo -e "\tFile $ix" | tee -a $1
					read -r -p $'\t'"Thank you. What will be your characterization for this file? You can choose multiple options, but must be comma separated (,) [t/d/a/n/m] " job
                    echo -e"\tThe job chosen was: $job" >> $1
					characterization $ix $output $job $1
				done
				;;
			*)
				echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
				exit
		esac