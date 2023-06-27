#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./pygenometracks_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1 
echo -e "\tpygenometracks\tUsed to plot multilple tracks into a image (similar to Genome Browser)" | tee -a $1
read -r -p $'\t'"How many plots do you want to perform? " number

if [ -z $number ];
then
    echo -e "\tSorry but no number of plots was provided. The program is goint to terminate" | tee -a $1
    exit
fi

echo -e "\tThe number of performed plots is going to be $number" >> $1

read -r -p $'\t'"At which plot do you want to start? If none is provided it will be considered 1 " ini

if [ -z $ini ];
then
    ini=1
fi

echo -e "\tThe initial number is going to be $ini" >> $1

read -r -p $'\t'"What would you like to name the folder to save the output(s)? " folder

if [ -z $folder ];
then
    echo -e "\tSorry but no folder was provided. The program is goint to terminate" | tee -a $1
    exit
fi

echo -e "\tThe folder for the outputs is: $folder" >> $1
mkdir -p $folder

read -r -p $'\t'"Are your tracks finished? [Y/n] " decision
case $decision in
	[yY]|[yY][eE][sS]|"")
        read -r -p $'\t'"What is the tracks file? " tracks

        if [ -z "$tracks" ];
        then
            echo -e "\tSorry but no tracks file was provided. The program is going to terminate"
            exit
        fi
        echo -e "\tThe tracks file already exists, and it's: $tracks" >> $1
        ;;
    [nN]|[nN][oO])
        echo -e "\Please construct the tracks file and then rerun the program. The program is going to terminate." | tee -a $1
		exit
		;;
    *)
		echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
		exit
		;;

esac

read -r -p $'\t'"Which name would you like to use for your outputs? Just give the name of the file, no path required " output

if [ -z "$output" ];
then
    echo -e "\tSorry, but not output name was provided. The program is going to terminate" | tee -a $1
    exit
fi

echo -e "\tThe output name is going to be: $output" >> $1

num=$(($number + $ini - 1))
for ix in $(seq $ini $num); do
    output_img=$folder
    output_img+="/"
    output_img+=$output
    output_img+="_"$ix".png"
    read -r -p $'\t'"Which region do you want to see? (example chr11:63558313-63631038) " region
    if [ -z "$region" ];
    then
        echo -e "\tSorry, but no region was provided. The program is going to terminate" | tee -a $1
        exit
    fi
    echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD pygenometracks pyGenomeTracks --tracks $tracks --region $region --outFileName $output_img --dpi 300 --width 20 --fontSize 8" >> $1
    udocker -q run -v=$PWD:$PWD -w=$PWD pygenometracks pyGenomeTracks --tracks $tracks --region $region --outFileName $output_img --dpi 300 --width 20 --fontSize 8
done