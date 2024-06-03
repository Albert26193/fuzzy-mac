#!/bin/bash

###################################################
# description: install fuzzy-mac files to ~/.fuzzy_mac
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fm_install_files {
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local util_file_path="${git_root}/src/scripts/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

    # Check if the script is executed as root
    if [[ "$(id -u)" -eq 0 ]]; then
        fm_print_error_line "Don't run this script as root." >&2
        return 1
    fi

    local target_dir="${HOME}/.fuzzy_mac"
    if [[ ! -d "${target_dir}" ]]; then
        fm_print_warning_line "${target_dir} not existed, create it"
        bash -c "mkdir ${target_dir}"
    fi

    if ! fm_yn_prompt "Do you want to copy ${FM_COLOR_GREEN}${git_root}/src (current dir)${FM_COLOR_RESET} to ${FM_COLOR_GREEN}${target_dir}(install dir)${FM_COLOR_RESET} ?"; then
        fm_print_white_line "Exit Now..."
        return 1
    fi

    if [[ ! -d "${git_root}/src" ]]; then
        fm_print_error_line "${git_root}/src not existed, please check."
        return 1
    fi

    if [[ $(ls -A "${target_dir}") ]]; then
        fm_print_green_line "ls -al ${target_dir} as below:"
        ls -al "${target_dir}"
        fm_print_warning_line "You should keep ${target_dir} empty."
        if ! fm_yn_prompt "${target_dir} is not empty, do you want to remove all files in it and continue?"; then
            fm_print_info_line "You should keep ${target_dir} empty. Remove all files in it manaully."
            fm_print_white_line "Exit Now..."
            return 1
        fi
        bash -c "rm -rf ${target_dir}/*"
        fm_print_green_line "${target_dir} is clear now."
    fi

    bash -c "cp -r ${git_root}/src/* ${target_dir}"

    if [[ -d "${target_dir}/scripts" ]] &&
        [[ -f "${target_dir}/config.env" ]]; then
        fm_print_white "copy successfully, ls -al"
        fm_print_info "${target_dir}"
        fm_print_white_line " as below:"
        ls -al "${target_dir}"
    else
        printf '%s\n' "${target_dir} copy failed."
    fi

    fm_print_green_line "Fuzzy-Mac files are deployed to ${target_dir} sucessfully. Congratulations! 🍺️"

    # check if has installed
    if cat "${HOME}/.zshrc" | grep -q ".fuzzy_mac"; then
        fm_print_white_line "already have fuzzy-mac script in ~/.zshrc"
        return 0
    fi

    echo -e "---------------------------------------------\n"
    fm_print_info_line "TIP: "
    fm_print_white_line "have already added below to your ~/.zshrc:"
    fm_print_green_line "   source ${HOME}/.fuzzy_mac/scripts/export.sh"
    fm_print_green_line "   source ${HOME}/.fuzzy_mac/config.env"
    fm_print_green_line "   alias "fs"="fuzzy_mac_search""
    fm_print_green_line "   alias "fj"="fuzzy_mac_jump""
    fm_print_green_line "   alias "fe"="fuzzy_mac_edit""
    fm_print_green_line "   alias "hh"="fuzzy_mac_history""

    echo '#------------------- fuzzy-mac -------------------
source "${HOME}/.fuzzy_mac/scripts/export.sh"
source "${HOME}/.fuzzy_mac/config.env"
alias "fs"="fuzzy_mac_search"
alias "fj"="fuzzy_mac_jump"
alias "fe"="fuzzy_mac_edit"
alias "hh"="fuzzy_mac_history"
#------------------- fuzzy-mac -------------------' >>"${HOME}/.zshrc"

    fm_print_white_line "then, exec 'source ~/.zshrc'"

    return 0
}

###################################################
# description: install dependency
#       input: none
#      return: 0: success | 1: fail
###################################################
function fm_install_dependency() {
    # load config file
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local util_file_path="${git_root}/src/scripts/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

    # Check if the script is executed as root
    if [[ "$(id -u)" -eq 0 ]]; then
        fm_print_error_line "DO NOT run this script as root." >&2
        return 1
    fi

    if ! command -v brew &>/dev/null; then
        fm_print_red_line "brew not installed, install it."
        return 1
    fi

    local all_install_list=(
        "fd"
        "fzf"
        "eza"
        "bat"
    )

    local to_install_list=()

    for package in "${all_install_list[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            fm_print_red "[ X ]"
            fm_print_red "${package}"
            fm_print_white_line "is not installed"
            to_install_list+=("${package}")
        else
            fm_print_green "[ √ ]"
            fm_print_blue "${package}"
            fm_print_white_line "is already installed."
        fi
    done

    # if all dependency installed, exit now
    if [[ ${#to_install_list[@]} -eq 0 ]]; then
        fm_print_green_line "All dependency installed, exit now..."
        return 0
    fi

    # if have dependency not installed, install it
    printf "\n"
    fm_print_yellow "🔧Here is the list of packages to install: "
    printf "${FM_COLOR_CYAN}%s${FM_COLOR_RESET} " "${to_install_list[@]}"
    printf "\n"
    fm_print_cyan_line "total count to install: ${#to_install_list[@]}"
    if fm_yn_prompt "Do you want to ${FM_COLOR_GREEN}install all dependency${FM_COLOR_RESET}?"; then
        fm_print_white_line "install dependency ..."
        brew install "${to_install_list[@]}"
    else
        fm_print_white_line "do not install dependency, exit now..."
        return 1
    fi
}

fm_install_dependency
fm_install_files
