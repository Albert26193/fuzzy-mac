#!/bin/bash

###################################################
# description: make output colorful
#          $1: input content
#      return: nothing
###################################################
FM_COLOR_RED="\033[31m"
FM_COLOR_GREEN="\033[32m"
FM_COLOR_YELLOW="\033[33m"
FM_COLOR_BLUE="\033[34m"
FM_COLOR_MAGENTA="\033[35m"
FM_COLOR_CYAN="\033[36m"
FM_COLOR_WHITE="\033[97m"
FM_COLOR_GRAY="\033[90m"
FM_COLOR_RESET="\033[0m"
FM_BACKGROUND_YELLOW="\033[43m"
FM_BACKGROUND_RED="\033[41m"
FM_BACKGROUND_GREEN="\033[42m"
FM_COLOR_WHITE="\033[97m"
FM_COLOR_BLACK="\033[1;30m"

fm_print_red_line() { printf "${FM_COLOR_RED}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_green_line() { printf "${FM_COLOR_GREEN}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_yellow_line() { printf "${FM_COLOR_YELLOW}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_blue_line() { printf "${FM_COLOR_BLUE}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_magenta_line() { printf "${FM_COLOR_MAGENTA}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_cyan_line() { printf "${FM_COLOR_CYAN}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_gray_line() { printf "${FM_COLOR_WHITE}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_white_line() { printf "${FM_COLOR_WHITE}%s${FM_COLOR_RESET}\n" "$1"; }

fm_print_red() { printf "${FM_COLOR_RED}%s${FM_COLOR_RESET} " "$1"; }
fm_print_green() { printf "${FM_COLOR_GREEN}%s${FM_COLOR_RESET} " "$1"; }
fm_print_yellow() { printf "${FM_COLOR_YELLOW}%s${FM_COLOR_RESET} " "$1"; }
fm_print_blue() { printf "${FM_COLOR_BLUE}%s${FM_COLOR_RESET} " "$1"; }
fm_print_magenta() { printf "${FM_COLOR_MAGENTA}%s${FM_COLOR_RESET} " "$1"; }
fm_print_cyan() { printf "${FM_COLOR_CYAN}%s${FM_COLOR_RESET} " "$1"; }
fm_print_gray() { printf "${FM_COLOR_WHITE}%s${FM_COLOR_RESET} " "$1"; }
fm_print_white() { printf "${FM_COLOR_WHITE}%s${FM_COLOR_RESET} " "$1"; }

fm_print_warning_line() { printf "${FM_BACKGROUND_YELLOW}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_error_line() { printf "${FM_BACKGROUND_RED}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}\n" "$1"; }
fm_print_info_line() { printf "${FM_BACKGROUND_GREEN}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}\n" "$1"; }

fm_print_warning() { printf "${FM_BACKGROUND_YELLOW}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}" "$1"; }
fm_print_error() { printf "${FM_BACKGROUND_RED}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}" "$1"; }
fm_print_info() { printf "${FM_BACKGROUND_GREEN}${FM_COLOR_BLACK}%s${FM_COLOR_RESET}" "$1"; }

###################################################
# description: give colorful yn_prompt
#          $1: custom prompt to print
#      return: 0: yes | 1: no
###################################################
function fm_yn_prompt() {
    local yn_input=""
    while true; do
        printf "$1 ${FM_COLOR_CYAN}[y/n]: ${FM_COLOR_RESET}"
        read yn_input
        case "${yn_input}" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) fm_print_red_line "Please answer yes[y] or no[n]." ;;
        esac
    done
}

###################################################
# description: print step information
#          $1: current step description
#      return: nothing
###################################################
function fm_print_step() {
    local current_step=$1
    fm_print_green_line "========================================="
    fm_print_green_line "================= STEP ${current_step} ================"
    fm_print_green_line "========================================="
}

###################################################
# description: get git root path
#      return: git root path
###################################################
function fm_get_gitroot() {
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "${git_root}" ]]; then
        fm_print_error_line "Error: git root not found, please run this script in your lso git repo."
        return 1
    fi

    echo "${git_root}"
    return 0
}

###################################################
# description: give current os judgement
#      return: Ubuntu | macOS | Debian | CentOS | Raspbian | Other
###################################################
function fm_check_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local OS=$(echo $NAME | awk '{print$1}')
    elif type lsb_release >/dev/null 2>&1; then
        local OS=$(lsb_release -si)
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        local OS=$DISTRIB_ID
    elif [[ -f /etc/debian_version ]]; then
        local OS=Debian
    elif [[ -f /etc/centos-release ]]; then
        local OS=CentOS
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        local OS=macOS
    else
        local OS=$(uname -s)
    fi

    case $OS in
    "Ubuntu" | "Debian" | "CentOS" | "macOS" | "Raspbian")
        echo $OS
        ;;
    *)
        echo "Other"
        ;;
    esac
}

###################################################
# description: check if /opt/lab-server-ops exists
#          $1: dir to check
#      return: 0: exist | 1: not exist
###################################################
function fm_check_dir() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        return 0
    else
        fm_print_error_line "Error: "${dir}" not exist, please INSTALL IT FIRST."
        fm_print_white_line "-----------------------------------------------------"
        fm_print_white_line "| You can install it by running:                    |"
        fm_print_white_line "|     1. cd to xxx/lab-server-ops                   |"
        fm_print_white_line "|     2. run ./deploy_opt/deploy_lso.sh             |"
        fm_print_white_line "-----------------------------------------------------"
        return 1
    fi
}

###################################################
# description: check branch name is matched with OS
#       input: branch to check
#      return: 0: exist | 1: not exist
###################################################
function fm_check_branch() {
    local current_branch="$(git rev-parse --abbrev-ref HEAD)" # master | linux | linux-minimum | mac-personal
    local current_os="$(fm_check_os)"

    local linux_release_version="$(uname -r | cut -d "." -f1)" # 5.4.0-42-generic --> 5

    if [[ ${current_os} == "macOS" ]] &&
        [[ ${current_branch} != "mac-personal" ]]; then
        fm_print_white_line "current OS: ${current_os}"
        fm_print_white_line "current Branch: ${current_branch}"
        fm_print_yellow_line "Warning: current branch is ${current_branch}, please checkout to mac-personal."
        if fm_yn_prompt "Would you like to checkout to ${FM_COLOR_GREEN}branch:mac-personal${FM_COLOR_RESET}?"; then
            git checkout mac-personal
            if [[ $? -ne 0 ]]; then
                fm_print_red_line "checkout to mac-personal failed, please check it."
                return 1
            else
                fm_print_green_line "checkout to mac-personal successfully."
                return 0
            fi
        else
            fm_print_red_line "abort checkout to branch:'mac-personal' ..."
            return 1
        fi
    fi

    if [[ ${current_os} != "Ubuntu" ]] &&
        [[ ${current_os} != "Debian" ]] &&
        [[ ${current_os} != "CentOS" ]] &&
        [[ ${current_os} != "Raspbian" ]] &&
        [[ ${current_os} != "macOS" ]]; then
        fm_print_red_line "Error: current os is NOT Support, please check it."
        fm_print_white_line "Support OS: Ubuntu | Debian | CentOS | macOS | Raspbian"
        return 1
    fi

    if [[ ${linux_release_version} -lt "5" ]] &&
        [[ ${current_branch} != "linux-minimum" ]]; then
        fm_print_white_line "current Release Version: "$(uname -r)""
        fm_print_yellow_line "your Linux Release Version is lower than 5, please check to linux-minimum branch."
        if fm_yn_prompt "Would you like to checkout to ${FM_COLOR_GREEN}branch:linux-minimum${FM_COLOR_RESET}?"; then
            git checkout linux-minimum
            if [[ $? -ne 0 ]]; then
                fm_print_red_line "checkout to 'linux-minimum' failed, please check it."
                return 1
            else
                fm_print_green_line "checkout to 'linux-minimum' successfully."
                return 0
            fi
        else
            fm_print_red_line "abort checkout to branch:'linux-minimum' ..."
            return 1
        fi
    fi

    if [[ ${linux_release_version} -ge "5" ]] &&
        [[ ${current_branch} != "linux" ]]; then
        fm_print_white_line "current Release Version: "$(uname -r)""
        fm_print_yellow_line "your Linux Release Version is higher than 5, please check to 'linux' branch."
        if fm_yn_prompt "Would you like to checkout to ${FM_COLOR_GREEN}branch:linux${FM_COLOR_RESET}?"; then
            git checkout linux
            if [[ $? -ne 0 ]]; then
                fm_print_red_line "checkout to 'linux' failed, please check it."
                return 1
            else
                fm_print_green_line "checkout to 'linux' successfully."
                return 0
            fi
        else
            fm_print_red_line "abort checkout to branch:'linux' ..."
            return 1
        fi
    fi

    clear
    fm_print_white_line "current OS              : ${current_os}"
    fm_print_white_line "current Release Version : "$(uname -r)""
    fm_print_white_line "current Branch          : ${current_branch}"
    fm_print_green_line "Your OS and Branch are matched 🟩, continue..."
    return 0
}

###################################################
# description: print branch rules
#      return: 0: success | 1: fail
###################################################
function fm_branch_rule() {
    fm_print_white_line "-----------------------------------------------------"
    fm_print_cyan_line "Support OS: Ubuntu | Debian | CentOS | macOS | Raspbian "
    fm_print_magenta_line "Current OS: $(fm_check_os)"
    fm_print_white_line "-----------------------------------------------------"
    fm_print_white "For"
    fm_print_green "MacOS(personal-use) ---> "
    fm_print_white_line "branch: mac-personal"

    fm_print_white "For"
    fm_print_green "Linux(kernel < 5): Ubuntu < 19.04 | CentOS 7/8 | Debian/Raspbian < 10 ---> "
    fm_print_white_line "branch: linux-minimum"

    fm_print_white "For"
    fm_print_green "Linux(kernel >= 5): Ubuntu >= 19.04 | Debian/Raspbian >=10 ---> "
    fm_print_white_line "branch: linux"

    fm_print_white_line "-----------------------------------------------------"
    printf "\n"

    return 0
}
