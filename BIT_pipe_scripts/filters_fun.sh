#!/bin/bash

var1=$(pwd)
var2="$var1/udocker"
export PATH="$var2":$PATH

if [ -z $1 ];
then
    set -- "./filters_report.log"
    > $1
fi

annotation_gene_fun () {
    read -r -p $'\t'"Do you have a genome annotation with only gene information? [y/N] " decision
    case "$decision" in
        [yY]|[yY][eE][sS])
            read -r -p $'\t'"What would be the annotation file with only gene information? " gene_annotation

            if [ -z "$gene_annotation" ];
            then
                echo -e "\tSorry, but no annotation file was provided. The program is going to terminate." | tee -a $1
                exit
            fi

            ;;
        [nN]|[nN][oO]|"")
            read -r -p $'\t'"What would be the annotation file? " annotation

            if [ -z "$annotation" ];
            then
                echo -e "\tSorry, but no annotation file was provided. The program is going to terminate." | tee -a $1
                exit
            fi

            echo -e "\tThe annotation file provided is: $annotation" >> $1

            local s=(${annotation//"."/ })
            local se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
            local form=${s[$((${#s[@]}-1))]}
                
            echo -e "\tawk -F'"\t"' '\$3 ~ /gene/ {print \$0}' $annotation > ."$se".gene.$form" >> $1
            awk -F'\t' '$3 ~ /gene/ {print $0}' $annotation > ."$se".gene.$form
            gene_annotation=."$se".gene.$form 
            ;;
        *)
            echo -e "\nI'm sorry but I don't understand your answer, so I'll consider it as a yes."
            read -r -p $'\t'"What would be the annotation file with only gene information? " gene_annotation

            if [ -z "$gene_annotation" ];
            then
                echo -e "\tSorry, but no annotation file was provided. The program is going to terminate." | tee -a $1
                exit
            fi
            ;;
        esac
    echo -e "\tThe gene annotation file provided is: $gene_annotation" >> $1
}

echo -e "\nHere we go:\n" | tee -a $1
echo -e "\tfilters\tUsed to filter out the BIT candidates results based on the user desire" | tee -a $1
read -r -p $'\t'"What BIT candidates file are you going to filter? " file

if [ -z "$file" ];
then
    echo -e "\tSorry, but no file was provided. The program is going to terminate." | tee -a $1
    exit
fi
echo -e "\tThe BIT candidates file is: $file" >> $1

read -r -p $'\t'"Are you files already with TSS coordinates? (Only needed if you ran a UPSTREAM model at the BIT_id function, and it's your first time using such file) [Y/n] " decision

case "$decision" in
    [yY]|[yY][eE][sS]|"")
        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    [nN]|[nN][oO])
        read -r -p $'\t'"What would be the file with the chromossome sizes? " chr_sizes

        if [ -z "$chr_sizes" ];
        then
            echo -e "\tSorry, but no file was provided. The program is going to terminate." | tee -a $1
            exit
        fi
        echo -e "\tThe chromossome sizes file provided is: $chr_sizes" >> $1

        s=(${file//"."/ })
        se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
        form=${s[$((${#s[@]}-1))]}

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools flank -i $file -g $chr_sizes -s -l 0 -r 1 > ."$se".tss."$form"" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools flank -i $file -g $chr_sizes -s -l 0 -r 1 > ."$se".tss."$form"
        file=."$se".tss."$form"
        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    *)
        echo -e "I'm sorry but I don't understand your answer, so I'll consider it as a yes and we are going to proceed.\n" | tee -a $1
        ;;
esac

read -r -p $'\t'"Do you want to filter for intragenic and intergenic TSS? [Y/n] " decision

case "$decision" in
    [yY]|[yY][eE][sS]|"")
        annotation_gene_fun $1

        s=(${file//"."/ })
        se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
        form=${s[$((${#s[@]}-1))]}

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -wa -u > ."$se".intragenic.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -wa -u > ."$se".intragenic.$form
        
        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -v > ."$se".intergenic.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -v > ."$se".intergenic.$form

        read -r -p $'\t'"What file would you like to keep applying filters to? (the default is intragenic) (if you desire to end here, just accept the default by pressing enter and answer the remaining options) [intragenic/intergenic] " decision

        case "$decision" in
            [iI][nN][tT][rR][aA][gG][eE][nN][iI][cC]|"")
                file=."$se".intragenic.$form
                decision="intragenic"
                ;;
            [iI][nN][tT][eE][rR][gG][eE][nN][iI][cC])
                file=."$se".intergenic.$form
                ;;
            *)
                echo -e "\tSorry, but no option was provided or properly written. The program is going to terminate." | tee -a $1
                exit
                ;;
        esac

        echo -e "\tThe file chosen is $decision" >> $1

        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    [nN]|[nN][oO])
        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    *)
        echo -e "I'm sorry but I don't understand your answer, so I'll consider it as a no and we are going to proceed.\n" | tee -a $1
        ;;
esac

read -r -p $'\t'"Do you want to filter for intragenic TSS by their strand? (eg. Same strand meaning in the same strand as the a gene in the same location) [Y/n] " decision

case "$decision" in
    [yY]|[yY][eE][sS]|"")
        
        if [ -z "$gene_annotation" ];
        then
            annotation_gene_fun $1
        fi

        s=(${file//"."/ })
        se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
        form=${s[$((${#s[@]}-1))]}

        read -r -p $'\t'"Do you want to same strand cases or opposite strand cases (i.e being same strand doesn't imply not being correspondent also to opposite strand, and vice-versa)? The important factor here is to choose the characteristic of interest (default is same) [same/opposite] " decision
        
        case "$decision" in
            [sS][aA][mM][eE]|"")
                echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -s -wa -u > ."$se".same_strand.$form" >> $1
                udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -s -wa -u > ."$se".same_strand.$form
                echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -s -v > ."$se".not_same_strand.$form" >> $1
                udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -s -v > ."$se".not_same_strand.$form
                file=."$se".same_strand.$form
                decision="same"
                ;;
            [oO][pP][pP][oO][sS][iI][tT][eE])
                echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -S -wa -u > ."$se".opposite_strand.$form" >> $1
                udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -S -wa -u > ."$se".opposite_strand.$form
                echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a $file -b $gene_annotation -S -v > ."$se".not_opposite_strand.$form" >> $1
                udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a $file -b $gene_annotation -S -v > ."$se".not_opposite_strand.$form
                file=."$se".opposite_strand.$form
                ;;
            *)
                echo -e "\tSorry, but no option was provided or properly written. The program is going to terminate." | tee -a $1
                exit
                ;;
        esac

        echo -e "\tThe method chosen is the $decision strand" >> $1

        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    [nN]|[nN][oO])
        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    *)
        echo -e "I'm sorry but I don't understand your answer, so I'll consider it as a no and we are going to proceed.\n" | tee -a $1
        ;;
esac

read -r -p $'\t'"If you have chosen same strand, do you want to filter the results by Canonical (i.e. this classification comes from the Ensembl tag canonical) and Non Canonical transcripts? [Y/n] " decision

case "$decision" in
    [yY]|[yY][eE][sS]|"")
        read -r -p $'\t'"Do you have a file with the 1st exon of each Canonical transcript? [Y/n] " decision
        
        case "$decision" in
            [yY]|[yY][eE][sS]|"")
                read -r -p $'\t'"What is the 1st exon of each Canonical transcript? " canonical

                if [ -z "$canonical" ];
                then
                    echo -e "\tSorry, but no annotation file was provided. The program is going to terminate." | tee -a $1
                    exit
                fi

                echo -e "\tThe file with the 1st exon of each Canonical transcript: $canonical" >> $1

                ;;
            [nN]|[nN][oO])
                echo -e "\nThank you. You should go to the R script and run the section related to such step. The program is going to terminate. Please rerun when you have the file ready." | tee -a $1
                exit
                ;;
            *)
                echo -e "\nI'm sorry but I don't understand your answer, so I'll consider it as a no. You should go to the R script and run the section related to such step. The program is going to terminate. Please rerun when you have the file ready." | tee -a $1
                exit
                ;;
        esac

        s=(${file//"."/ })
        se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
        form=${s[$((${#s[@]}-1))]}

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a  $file -b $canonical -s -wa -u > ."$se".canonical_cases.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a  $file -b $canonical -s -wa -u > ."$se".canonical_cases.$form

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools intersect -a  $file -b $canonical -s -v > ."$se".non_canonical_cases.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools intersect -a  $file -b $canonical -s -v > ."$se".non_canonical_cases.$form

        read -r -p $'\t'"What file would you like to keep applying filters to? (the default is not, standing for not canonical) (if you desire to end here, just accept the default by pressing enter and answer the remaining options) [canonical/not]" decision
        
        case "$decision" in
            [cC][aA][nN][oO][nN][iI][cC][aA][lL])
                file=."$se".canonical_cases.$form
                ;;
            [nN][oO][tT]|"")
                file=."$se".non_canonical_cases.$form
                decision="not"
                ;;
            *)
                echo -e "\tSorry, but no option was provided or properly written. The program is going to terminate." | tee -a $1
                exit
                ;;
        esac

        echo -e "\tThe file chosen is $decision" >> $1

        echo -e "\nThank you. We are going to proceed" | tee -a $1
        ;;
    [nN]|[nN][oO])
        echo -e "\nThank you. We are going to proceed" | tee -a $1
        ;;
    *)
        echo -e "\nI'm sorry but I don't understand your answer, so I'll consider it as a no and we are going to proceed." | tee -a $1
        ;;
esac

read -r -p $'\t'"Do you want to check the closest CpG island and TATA box? [Y/n] " decision

case "$decision" in
    [yY]|[yY][eE][sS]|"")
        read -r -p $'\t'"What is the file with CpG island information? If sorted version, please provide it " cpg_file

        if [ -z "$cpg_file" ];
        then
            echo -e "\tSorry, but no file was provided. The program is going to terminate" | tee -a $1
            exit
        fi

        echo -e "\tThe CpG islands file is $cpg_file"

        read -r -p $'\t'"Do you want to sort the file? [Y/n] " sorting

        case "$sorting" in
            [yY]|[yY][eE][sS]|"")
                s=(${cpg_file//"."/ })
                se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
                form=${s[$((${#s[@]}-1))]}
                echo -e "\tsort -k1,1 -k4,4n -k5,5n $cpg_file > ."$se".sorted.$form" >> $1
                sort -k1,1 -k4,4n -k5,5n $cpg_file > ."$se".sorted.$form
                cpg_file=."$se".sorted.$form
                echo -e "\tThe CpG islands sorted file is $cpg_file"
                echo -e "Now it's sorted. Let's proceed.\n" | tee -a $1
                ;;
            [nN]|[nN][oO])
                echo -e "Thank you. Let's proceed.\n" | tee -a $1
                ;;
            *)
                echo -e "\tSorry, but I don't understand your answer. The program is going to terminate" | tee -a $1
                exit
                ;;
            
        esac

        read -r -p $'\t'"What is the file with TATA box information? If sorted version, please provide it " tata_file

        if [ -z "$tata_file" ];
        then
            echo -e "\tSorry, but no file was provided. The program is going to terminate" | tee -a $1
            exit 
        fi

        echo -e "\tThe TATA box file is $tata_file"

        read -r -p $'\t'"Do you want to sort the file? [Y/n] " sorting

        case "$sorting" in
            [yY]|[yY][eE][sS]|"")
                s=(${tata_file//"."/ })
                se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
                form=${s[$((${#s[@]}-1))]}
                echo -e "\tsort -k1,1 -k4,4n -k5,5n $tata_file > ."$se".sorted.$form" >> $1
                sort -k1,1 -k4,4n -k5,5n $tata_file > ."$se".sorted.$form
                tata_file=."$se".sorted.$form
                echo -e "\tThe TATA box sorted file is $tata_file"
                echo -e "Now it's sorted. Let's proceed.\n" | tee -a $1
                ;;
            [nN]|[nN][oO])
                echo -e "Thank you. Let's proceed.\n" | tee -a $1
                ;;
            *)
                echo -e "\tSorry, but I don't understand your answer. The program is going to terminate" | tee -a $1
                exit
                ;;
            
        esac

        read -r -p $'\t'"Is the file for the analysis (the one of the BIT's) sorted? [y/N] " sorting

        case "$sorting" in
            [yY]|[yY][eE][sS])
                echo -e "Thank you. Let's proceed.\n" | tee -a $1
                ;;
            [nN]|[nN][oO]|"")
                s=(${file//"."/ })
                se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
                form=${s[$((${#s[@]}-1))]}
                echo -e "\tsort -k1,1 -k2,2n -k3,3n $file > ."$se".sorted.$form" >> $1
                sort -k1,1 -k4,4n -k5,5n $file > ."$se".sorted.$form
                file=."$se".sorted.$form
                echo -e "\tThe BIT sorted file is $file"
                echo -e "Now it's sorted. Let's proceed.\n" | tee -a $1
                ;;
            *)
                echo -e "\tSorry, but I don't understand your answer. The program is going to terminate" | tee -a $1
                exit
                ;;
            
        esac

        s=(${file//"."/ })
        se=$(IFS=. ; echo "${s[*]:0:$((${#s[@]}-1))}")
        form=${s[$((${#s[@]}-1))]}

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools closest -a $file -b $cpg_file -D a > ."$se".closest_cpg.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools closest -a $file -b $cpg_file -D a > ."$se".closest_cpg.$form

        echo -e "\tudocker -q run -v=\$PWD:\$PWD -w=\$PWD htstools bedtools closest -a $file -b $tata_file -s -D a > ."$se".closest_tata.$form" >> $1
        udocker -q run -v=$PWD:$PWD -w=$PWD htstools bedtools closest -a $file -b $tata_file -s -D a > ."$se".closest_tata.$form

        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    [nN]|[nN][oO])
        echo -e "Thank you. We are going to proceed\n" | tee -a $1
        ;;
    *)
        echo -e "I'm sorry but I don't understand your answer, so I'll consider it as a no and we are going to proceed.\n" | tee -a $1
        ;;
esac