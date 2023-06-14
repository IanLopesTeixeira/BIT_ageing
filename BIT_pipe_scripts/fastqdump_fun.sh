#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./fastqdump_report.log"
    > $1
fi

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tfastqdump\tUsed for downloading files" | tee -a $1
read -r -p $'\t'"What are the SRR files that you want to obtain? If you want multiple SRR files, please make them space separated ( ) " -a files
echo -e "\tThe files provided are: ${files[@]}" >> $1
if [ -z "$files" ];
	then
		echo -e "\tSorry, but no file(s) have been provided. The program is going to terminate" | tee -a $1
    	exit
fi
read -r -p $'\t'"Do you want to specify a folder to move your files (partially or all)? [Y/n] " decision 
case $decision in
	[yY]|[yY][eE][sS]|"")
		read -r -p $'\t'"Thank you. Will you specify the same folder for each file or not? [same/different] " folder
		if [ "$folder" == "same" ];
		then
			read -r -p $'\t'"Thank you. Which folder will it be? " folder
            echo -e "\tYou decided to move all your files to this folder: $folder" >> $1			
			mkdir -p $folder
			if [ -z "$folder" ];
			then
				echo -e "\tSorry, but no folder has been provided. The program is going to terminate" | tee -a $1
    			exit
			fi
			mkdir -p $folder
			for ix in "${files[@]}";do
				echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD sra-tools fasterq-dump --split-files "$ix"" >> $1
				udocker -q run -v="$PWD":"$PWD" -w="$PWD" sra-tools fasterq-dump --split-files "$ix"
				mv "$ix"* "$folder"			
       		done

		elif [ "$folder" == "different" ];
		then
			echo -e "\tThank you. You'll be asked, per file, which folder you desire."
            echo -e "\tYou'll be asked, per file, which folder you desire." >> $1
			for ix in "${files[@]}";do
                echo -e "\tThe current file is $ix" | tee -a $1
                echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD sra-tools fasterq-dump --split-files "$ix"" >> $1
                udocker -q run -v="$PWD":"$PWD" -w="$PWD" sra-tools fasterq-dump --split-files "$ix"
				read -r -p $'\t'"Which folder you want to save this file? The folder must already be created. If no folder is given, it will be mantainned in the current directory. " folder

				if [ -z "$folder" ];
				then
					echo -e "\tSorry, but no folder has been provided. The program is going to terminate" | tee -a $1
    				exit
				fi
                
				mkdir -p $folder
                echo -e "It will be moved to folder: $folder" | tee -a $1
				mv "$ix"* "$folder"
				
    		done

		else
			echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
			exit
		fi
		;;	
	[nN]|[nN][oO])
		echo -e "\tThank you. It will be outputted on the current directory." | tee -a $1
				
		for ix in "${files[@]}";do
            echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD sra-tools fasterq-dump --split-files "$ix"" >> $1
            udocker -q run -v="$PWD":"$PWD" -w="$PWD" sra-tools fasterq-dump --split-files "$ix"                    
		done
		;;
    *)
		echo -e "\tSorry, I can't understand your option. The program is going to terminate." | tee -a $1
		exit
		;;
esac