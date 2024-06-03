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
