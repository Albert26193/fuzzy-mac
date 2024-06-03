#!/bin/bash

###################################################
# description: fuzzy history search
#       input: none
#      return: matched command in history
###################################################
function fuzzy_mac_history() {
    # source utils.sh
    local fm_root="${HOME}/.fuzzy_mac"
    local util_file_path="${fm_root}/src/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist. Install Fuzzy-Mac first."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

    local history_awk_script='{
        $1=""
        $2=""
        $3=""
        print $0
    }'

    local selected_command=$(history -i | fzf | awk "${history_awk_script}" | tr -d '\n' | awk '{gsub(/^ */, ""); print}')

    fm_print_white "you have selected:"
    fm_print_info_line "${selected_command}"

    if fm_yn_prompt "sure to execute the command?"; then
        eval "${selected_command}"
    else
        printf "${FM_COLOR_YELLOW}%s${FM_COLOR_RESET}\n" "NOT execute the command"
        if [[ "$(which pbcopy)" ]] && fm_yn_prompt "copy the command into your OS clip board?"; then
            eval "echo "${selected_command}" | pbcopy"
            printf "%s\n" "first line in OS clip board:"
            printf "${FM_COLOR_GREEN}%s${FM_COLOR_RESET}\n" "$(pbpaste >&1)"
            echo "just paste it"
        else
            printf "${FM_COLOR_YELLOW}%s${FM_COLOR_RESET}\n" "Exit Now..."
        fi
    fi
}
