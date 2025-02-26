#!/usr/bin/env bash

# s_utils.sh
# 06.01.2024 [ru_RU]
# Boris Spiridonov
# Last Modified: 26.02.2025 11:40:41

printPelp() {
    cat <<EOF
Usage: $(basename "${0}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

The arg1 is a required argument.
The arg2 is a optional argument.

Available options:

-h, --help      Print this help and exit.
-v, --verbose   Print script debug info.
-f, --flag      Some flag description.
-p, --param     Some param description,
                param_value description.
-a              Вывести все объекты.
-c              Произвести подсчёт.
-d              Указать директорию.
-e              Развернуть объект.
-f              Указать файл, из которого нужно прочитать данные.
-h              Вывести справку по команде.
-i              Игнорировать регистр символов.
-l              Выполнить полноформатный вывод данных.
-n              Использовать неинтерактивный (пакетный) режим.
-o              Позволяет указать файл, в который нужно перенаправить вывод.
-q              Выполнить скрипт в quiet-режиме.
-r              Обрабатывать папки и файлы рекурсивно.
-s              Выполнить скрипт в silent-режиме.
-v              Выполнить многословный вывод.
-x              Исключить объект.
-y              Ответить «yes» на все вопросы.
--list-only     Вывести на экран вывод прогаммы как при выволнении, но не чего не делать на самом деле.

Dependency:

EOF
    exit 0
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

init() {
    # preparations and initialization
    # set trap if needs

    set -Eeuo pipefail
    trap cleanup SIGINT SIGTERM ERR EXIT

    readonly SCRIPT_DIR=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

    readonly DATE=$(date "+%Y/%m/%d_%H:%M:%S")
    readonly NEW_LINE="\n"
}

setupColors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT="\033[0m" \
        RED="\033[0;31m" \
        GREEN="\033[0;32m" \
        ORANGE="\033[0;33m" \
        BLUE="\033[0;34m" \
        PURPLE="\033[0;35m" \
        CYAN="\033[0;36m" \
        YELLOW="\033[1;33m"
    else
        NOFORMAT="" \
        RED="" \
        GREEN="" \
        ORANGE="" \
        BLUE="" \
        PURPLE="" \
        CYAN="" \
        YELLOW=""
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg="${1}"
    local code="${2:-1}" # default exit status 1
    msg "${msg}"
    exit "${code}"
}

#die() {
#    warn "$@"
#    exit 1
#}
#
#warn() {
#    catecho "$@" >&2
#}
#
#catecho() {
#    [ -t 0 ] && echo "$@" || cat -
#}

parseOptions() {
    # default values of variables set from params
    flag=0
    param=''

    while :; do
        case "${1-}" in
        -h | --help) printPelp;;
        -v | --verbose) set -x ;;
        --no-color) NO_COLOR=1 ;;
        -f | --flag) flag=1 ;; # example flag
        -p | --param) # example named parameter
          param="${2-}"
          shift
          ;;
        -?*) die "Unknown option: "${1}"" ;;
        *) break ;;
        esac
        shift
    done

    args=("${@}")

    # check required params and arguments
    [[ -z "${param-}" ]] && die "Missing required parameter: param"
    [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

    return 0
}

asciiToHex() {
    printf "%s" "${@}" | xxd -p -u
}

hexToAscii() {
    echo "${@}" | xxd -r -p
}

binaryToHex() {
    printf "%x" "$((2#"${@}"))"
}

binaryToDecimal() {
    echo "$((2#"${@}"))"
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

isFileExists() {
    local filePath="${1:-""}"

    local result=-1

    [[ -f "${filePath}" ]] && result=0

    return "${result}"
}

isDirExists() {
    local dirPath="${1:-""}"

    local result=-1

    [[ -d "${dirPath}" ]] && result=0

    return "${result}"
}

getExtension() {
    local result=-1

    if [[ -f "${1}" ]]; then
        result="${1##*.}"
    else
        msg "File "${1}" not found"
    fi
        echo "${result}"
}

getFileName() {
    local result=-1
    local file="${1##*/}"

    if [[ -f "${1}" ]]; then
        result="${file%.*}"
    else
        msg "File "${1}" not found"
    fi
        echo "${result}"
}

getDir() {
    local result=-1
    local dir="${1%/*}"

    if [[ -d "${dir}" ]]; then
        result="${dir}"
    else
        msg "Directory "${1}" not found"
    fi
        echo "${result}"
}

#isNotSet() {
#    local result=1
#
#    [[ -z "${@+"set"}" ]] && result=0
#
#    return "${result}"
#}

isProgExists() {
    local result=1

    hash "${@}" > /dev/null 2>&1 && result=0

    return "${result}"
}

getDayOfWeek() {
    local dayOfWeek="$(date +%u)"

    echo "${dayOfWeek}"
}

getDayOfMonth() {
    local dayOfMonth="$(date +%d)"

    echo "${dayOfMonth}"
}

getMonth() {
    local month="$(date +%m)"

    echo "${month}"
}

getNextMonth() {
    local nextMonth="$(date -d "+1 month" "+%m")"

    echo "${nextMonth}"
}

getFormerMonth() {
    local formerMonth="$(date -d "-1 month" "+%m")"."$(date +%y)" 

    echo "${formerMonth}"
}

getYear() {
    local year="$(date +%y)"

    echo "${year}"
}

isEmpty() {
    local result=1

    [[ -z "${@-"unset"}" ]] && result=0

    return "${result}"
}

isStringContain() {
    local result=1

    local string="${1}"
    local subString="${2}"

    [[ "${string}" == *"${subString}"* ]] && result=0

    return "${result}"
}

isNotEmpty() {
    local result=1

    [[ -n "${@}" ]] && result=0

    return "${result}"
}

isRoot() {
    local result=-1

    if [[ "$(id -u)" == 0 ]]; then
        result=0
    else
        msg "This script NOT have root mode"
    fi

    echo "${result}"
}

rootCheck() {
    if [[ $(isRoot) != 0 ]]; then
        die "This script must start at root or use sudo."
    fi
}

getUser() {
    local user="$(id -u -n)"

    echo "${user}"
}

isBashVersion() {
    local version="${1}"
    local result=-1

    if [[ "${BASH_VERSINFO[0]}" -ge "${version}" ]]; then
        result=0
    fi

    echo "${result}"
}

bashCheck() {
    local version="${1:-4}"

    if [[ "$(isBashVersion "${version}")" != 0 ]]; then
        die "Bash "${version}".0+ required"
    fi
}

isLibrary() {
    local result=-1

    (( "${#BASH_SOURCE[@]}" > 3 )) && {
        result=0
    }

    echo "${result}"
}

libraryCheck() {
    (( "$(isLibrary)" == 0 )) || {
    die ""${BASH_SOURCE[0]}" Only source this as libraries"
    }
}

alreadySeen() {
    local deep=$(("${#BASH_SOURCE[@]}"-1))
    local namespace="${BASH_SOURCE["${deep}"]}"
    local result=1

    [[ -v "${already_evaled[0]}" ]] || declare -Ag already_evaled
    [[ ${already_evaled["${namespace}"]} ]] || result=0
    already_evaled["${namespace}"]=1

    return "${result}"
}

# getHead: Get the head part of string
# getHead "test_string" 3 # Return tes
getHead() {
    local string="${1:-""}"
    local part="${2:-0}"

    local result=""

    result="${string:0:part}"

    return "${result}"
}

# getTail: Get the tail part of string
# getTail "test_string" 3 # Return ing
getTail() {
    local string="${1:-""}"
    local part="${2:-0}"

    local result=""

    result="${string:"${#string}"-part:part}"

    return "${result}"
}

# ord: The ASCII value of a character
# ord A # Return 65
ord() {
    printf "%d" "\""${1}""
}

# chr: The charater represented by thegiven ASCII decimal value
# chr 65 # Return A
chr() {
    printf "\x"$(printf "%x" "${1}")""
}

isArray() {
    local result=1

    [[ "$(declare -p "${@}")" =~ "declare -a" ]] && result=0

    return "${result}"
}

# getArrayIndexes array[@]
getArrayIndexes() {
    declare -a array=("${!1}")

    local result=""

    result="${!array[*]}"

    echo "${result}"
    return "${result}"
}

# getArraySize array[@]
getArraySize() {
    declare -a array=("${!1:-""}")

    local result=0

    result=${#array[*]}

    echo "${result}"
    return "${result}"
}

# forEach ls echo 
forEach() {
    local each="${1:-1}"
    local comm="${2:-""}"

    for i in "${each}"; do
        "$(comm "${i}")"
    done
}
