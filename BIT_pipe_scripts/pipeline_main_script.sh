#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH
#echo $PATH

decision_b=false
step_b=false
report_fun=./BIT_pipe_scripts/report_file_fun.sh
fastqdump=./BIT_pipe_scripts/fastqdump_fun.sh
fastqc=./BIT_pipe_scripts/fastqc_fun.sh
multiqc=./BIT_pipe_scripts/multiqc_fun.sh
genome_indexing=./BIT_pipe_scripts/genome_indexing_fun.sh
transcriptome_assembly_str=./BIT_pipe_scripts/transcriptome_assembly_str_fun.sh
align_flagstat=./BIT_pipe_scripts/align_flagstat_fun.sh
transcriptome_annotation=./BIT_pipe_scripts/transcriptome_annotation_fun.sh
dsb_characterization=./BIT_pipe_scripts/dsb_characterization_fun.sh
BIT_id=./BIT_pipe_scripts/BIT_id_fun.sh
processing=./BIT_pipe_scripts/processing_fun.sh
pygenometracks=./BIT_pipe_scripts/pygenometracks_fun.sh
converter=./BIT_pipe_scripts/converter_fun.sh

#pipeline_usage () {}
#give options to transcriptome assembly for annotation and genome indexing. need to alter this file and the function one
#transcriptome annotation not finnished
#need to fix the processer_fun for multilple formats
#pygenometracks not finished
#fix file converter and add

functions_usage () { echo -e "\tFUNCTION NAME\tDESCRIPTION\n\tfastqdump\tUsed for downloading files\n\tfastqc\tUsed for analysing the quality of fastq files\n\tmultiqc\tUsed for analysing the quality of multiple processes, namely transcriptome assembly\n\tgenome_indexing\tUsed for indexing the the genome\n\ttranscriptome_assembly_str\tUsed for transcriptome assembly, by using stringtie pipeline\n\talign_flagstat\tUsed to see some statistics about the alignment using samtools flagstat\n\ttranscriptome_annotation\tUsed for annotate the transcriptome file and compare with reference annotation, using gffcompare\n\tBIT_id\tUsed for identification of BIT locations\n\tprocessing\tUsed for processing multiple files\n\tdsb_characterization\tUsed for characterize DSB files\n\tpygenometracks\tUsed to plot multilple tracks into a image (similar to Genome Browser)\n\tconverter\tUsed to convert files into other formats\n\ttranscriptome_merge\tUsed for merging multilple transcriptomes created with Stringtie into a single transcriptome file (GTF)" 1>&2; }

echo -e "Hello, you are running the Pipeline for BIT (Break-Induced Transcription) location. Multiple functions are available, some of which aren't directly related to it."
echo -e "\n------------------------------------------------------------\n"

echo -e "To firstly run this. I'll need to make sure we are selecting a report file. Let's choose it"

source $report_fun

report_file=$rep_f

echo -e "\n-------------------------------------------------------$(date)----------------------------------------------------\n" | tee -a "$report_file"

tmp_file=$(mktemp)
while [ "$decision_b" != "true" ]; do

	read -r -p 'Do you wish to check which functions are available [Y/n]: ' decision
	case $decision in
		[yY]|[yY][eE][sS]|"")
			echo -e "\nThank you. Here are the available functions and their focus."
                	functions_usage
                	decision_b=true
			;;
		[nN]|[nN][oO])
			echo -e "\nThank you. No information will be displayed."
                	decision_b=true
			;;
		*)
			echo -e "\nI'm sorry but I wasn't programmed to understand your answer, can you please answer me again with either yes or no."
               		decision_b=false
			;;
	esac
done

echo -e "\n------------------------------------------------------------\n"

while [ "$step_b" != "true" ]; do
	read -r -p "It's now time to choose what we are going to do. Which function or pipeline do you want? " step

	if [ "$step" == "fastqdump" ];
	then
		{ time $fastqdump $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true	
	elif [ "$step" == "fastqc" ];
	then
		{ time $fastqc $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "multiqc" ];
	then
		{ time $multiqc $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "genome_indexing" ];
	then
		{ time $genome_indexing $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "transcriptome_assembly_str" ];
	then
		{ time $transcriptome_assembly_str $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "align_flagstat" ];
	then
		{ time $align_flagstat $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "transcriptome_annotation" ];
	then
		{ time $transcriptome_annotation $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file	
		step_b=true
	elif [ "$step" == "dsb_characterization" ];
	then
		{ time $dsb_characterization $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "BIT_id" ];
	then
		{ time $BIT_id $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "processing" ];
	then
		{ time $processing $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "pygenometracks" ];
	then
		{ time $pygenometracks $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "converter" ];
	then
		{ time $converter $report_file; } 2>&1 | tee $tmp_file
		echo -e "\n" >> $report_file
		tail -n 3 $tmp_file >> $report_file
		rm $tmp_file
		step_b=true
	elif [ "$step" == "transcriptome_merge" ];
	then
		echo -e "\nHere we go:\n"
		echo -e "\ttranscriptome_merge\tUsed for merging multilple transcriptomes created with Stringtie into a single transcriptome file (GTF)"
		read -r -p $'\t'"Which transcriptomes you want to merge? They need to be space separated ( ) " transcriptomes
		read -r -p $'\t'"Do you have a transcriptome annotation to give? [Y/n] " decision
		case $decision in
			[yY]|[yY][eE][sS]|"")
				read -r -p $'\t'"Thank you. Which is the transcriptome annotation? It needs to be a GTF file " annotation_ref
				genome="-G "$annotation_ref
				;;
			[nN]|[nN][oO])
				echo -e "\tThank you. No annotation will be used."
				genome=""
				;;
			*)
				echo -e "\tSorry, I can't understand your option. The program is going to terminate."
				exit
		esac
		read -r -p $'\t'"What name would you like to save your merged transcript? " output
		if [ -z $output ];
		then
			read -r -p $'\t'"No output was given, this will be terminated."
			exit
		fi
		echo udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie --merge $genome -o $output $transcriptomes
		udocker -q run -v=$PWD:$PWD -w=$PWD stringtie stringtie --merge $genome -o $output $transcriptomes
		step_b=true
	else
		echo -e "\n\tThis option is not available or badly writen. Please read the available functions and try again\n"
		functions_usage
		step_b=false
	fi
done

echo -e "\n------------------------------------------------------------\n"
echo -e "It's done. Thank you for using me" | tee -a $report_file

