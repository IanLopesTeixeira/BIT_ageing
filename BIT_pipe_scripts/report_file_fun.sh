#!/bin/bash


prefix_choosing () {
    local prefix
    read -r prefix
    while [ -z "$prefix" ]; do
        local prefix
        read -r -p "Sorry I didn't receive any input. Can you provide it again? " prefix
    done
    local decision
    read -r -p "Thank you. The file will have the following name: "$prefix".report_BIT_script.log . Do you confirm your choice? [Y/n] " decision
        case "$decision" in
            [yY]|[yY][eE][sS]|"")
                echo -e "\nThank you.The file will be created"
                report_file="$prefix.report_BIT_script.log"
                > "$report_file"
                ;;
            [nN]|[nN][oO])
                echo -e "\nThank you. Which prefix would you like to give to the file? "
                prefix_choosing 
                ;;
            *)
                echo -e "\nI'm sorry but I don't understand your answer, so I'll consider it as a no. Which prefix would you like to give to the file? "
                prefix_choosing
                ;;
        esac
}

file_choosing () {
    local files=("$@")
    echo -e "These are the existing files:\n${files[@]}"
    local chosen_file
    read -r -p "Which of this files would you like use? If you don't want to use any of them and create a new one, please just press enter " chosen_file
    if [ -z "$chosen_file" ];
    then
        echo -e "Thank you. We are going to create a new report. Which prefix would you like to give to the file? " 
        prefix_choosing
    else
        if [[ "${files[*]}" =~ "${chosen_file}" ]];
        then
            echo -e "Thank you. This will be your output file "$chosen_file". Further information will be appended to it without deleting previous one."
            report_file="$chosen_file"
        else
            echo -e "The name you've given does not const on the list."
            file_choosing "${files[@]}"
        fi
    fi
}

echo -e "We are going to check for previous reports:"
files=($(find . -name "*.report_BIT_script.log" 2>/dev/null | tr "\n" " "))
if [ -z "$files" ];
then
    echo -e "No files were found. We are going to create one. Which prefix would you like to give to the file? " 
    prefix_choosing
else
    file_choosing ${files[@]}
fi

export rep_f=$report_file
