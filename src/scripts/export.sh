#!/bin/bash

###################################################
# description: source execute files
#       input: none
#      return: 0: success | 1: fail
###################################################
function fm_source_user() {

    # Check if the script is sourced
    local script_file="${HOME}/.fuzzy_mac/scripts"

    if [[ ! -d "${script_file}" ]]; then
        printf "%s\n" "${script_file} do not exist. Install Fuzzy-Mac first."
        printf "%s\n" "Exit Now..."
        return 1
    fi

    source "${script_file}/fzf/fzf_history.sh"
    source "${script_file}/fzf/fzf_search.sh"
}

fm_source_user
