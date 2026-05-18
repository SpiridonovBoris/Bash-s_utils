#!/usr/bin/env bash

# s_utils.sh
# 06.01.2024 [ru_RU]
# Boris Spiridonov
# Last Modified: 19.05.2026 00:40:00

S_UTILS_VERSION="0.1.1"

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
    rm -f "${RESPONSE_PIPE}"
}

init() {
    # preparations and initialization
    # set trap if needs

    set -Eeuo pipefail
    trap cleanup SIGINT SIGTERM ERR EXIT

    readonly SCRIPT_DIR=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

    readonly DATE=$(date "+%Y/%m/%d_%H:%M:%S")
    readonly NEW_LINE="\n"

    readonly RESPONSE_PIPE=""${HOME}"/response_pipe"
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

isTerminal () {
    [ -t 0 ]
}

catecho() {
    isTerminal && echo -e "$@" || cat -
}

msg() {
    catecho "$@" >&2
}

die() {
    local text="${1:-""}"
    local code="${2:-1}" # default exit status 1

    msg "${text}"
    exit "${code}"
}

# xor: Get bit XOR
# xor 1234 0x0000 # Return 1234
# xor 1234 0xFFFF # Return 64301
xor () {
    local crc="${1}"
    local xor="${2:-0xFFFF}"

    echo $(( crc ^ xor ))
}

# bitReversal: Get bit reversal
# bitReversal 0x1234 16 # Return
bitReversal() {
    local data="${1}"
    local bits="${2:-8}"

    local result=0
    local i=0

    for ((i=0; i<"${bits}" ; i++)); do
        result=$(( (result << 1) | (data & 1) ))
        data=$(( data >> 1 ))
    done

    echo $(( result & ((1 << bits) - 1) ))
}

# getCrc16: Calculate CRC16 checksum for ModBus RTU
# Poly    Init   RefIn  RefOut  XorOut
# 0x8005  0xFFFF true   true    0x0000
# getCrc16 05050001FF00 # Return DC7E
# getCrc16 05050001FF00 0x8005 # Return DC7E
getCrc16 () {
    local data="${1}"
    local polynomial="${2:-0x8005}"

    local ref_in="${3:-true}"    # true/false
    local ref_out="${4:-true}"   # true/false
    local xor_out="${5:-0x0000}" # hex, e.g. 0x0000

    local crc=0xFFFF
    local byte=0
    local reversalByte=0

    for (( i=0; i<${#data}; i+=2 )); do
        byte=$(( 16#${data:i:2} ))

        processedByte=$byte
        if [[ "${ref_in}" = "true" ]]; then
            reversalByte=$( bitReversal $byte 8 )
        fi

        crc=$(( crc ^ ("${reversalByte}" << 8) ))

        for (( j=0; j<8; j++ )); do
            if (( (crc & 0x8000) )); then
                crc=$(( ((crc << 1) & 0xFFFF) ^ polynomial ))
            else
                crc=$(( (crc << 1) & 0xFFFF ))
            fi
        done

    done

    if [[ "${ref_out}" = "true" ]]; then
        crc=$( bitReversal "$crc" 16 )
    fi

    crc=$(xor $crc 0x0000)

    # CRC in little-endian format
    local crc_low=$((crc & 0xFF))
    local crc_high=$(( (crc >> 8) & 0xFF))
    printf "%02X%02X" $crc_low $crc_high
}

# intToBase: An integer number into another representation with another base
# intToBase 4 2 # Return 001
intToBase () {
    local number="${1}"
    local base="${2}"
    local result=""

    while [[ "${number}" -ne 0 ]]; do
        result="${result}""$(( "${number}" % "${base}"))"
        number="$(( "${number}" / "${base}"))"
    done

    echo -n "${result}"
}

# decimalToBinary 4 # Return 001
decimalToBinary () {
    intToBase "${@}" 2
}

decimalToHex() {
    printf "%02x" "${@}"
}

asciiToHex() {
    #printf "%s" "${@}" | xxd -u -p
    printf "%x" "'${@}"
}

binaryToHex() {
    printf "%x" "$((2#"${@}"))"
}

hexToAscii() {
    echo -n "${@}" | xxd -r -p
}

binaryToDecimal() {
    echo -n "$((2#"${@}"))"
}

hexToDecimal() {
    echo -n $(printf "%d" 0x"${@}")
}

hexToSignedDecimal() {
    local max_signed_integer=32767
    local max_unsigned_integer=65536
    local result=$(hexToDecimal "${@}")

    [[ $result -gt $max_signed_integer ]] && result=$(( $result - $max_unsigned_integer ))

    echo -n $result
}

hexToBinary () {
    local result=-1
    local hex="${1}"
    local bin=""

    for ((i = 0; i < ${#hex}; i++)); do
        case "${hex:$i:1}" in
            0)   bin+="0000" ;;
            1)   bin+="0001" ;;
            2)   bin+="0010" ;;
            3)   bin+="0011" ;;
            4)   bin+="0100" ;;
            5)   bin+="0101" ;;
            6)   bin+="0110" ;;
            7)   bin+="0111" ;;
            8)   bin+="1000" ;;
            9)   bin+="1001" ;;
            A|a) bin+="1010" ;;
            B|b) bin+="1011" ;;
            C|c) bin+="1100" ;;
            D|d) bin+="1101" ;;
            E|e) bin+="1110" ;;
            F|f) bin+="1111" ;;
            *)   bin="Fail"  ;;
        esac
    done

    result="${bin}"
    echo -n "${result}"
}

stringToInt () {
    echo -n "$(("${@}"))"
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

# isFileExists /tmp/fileName.ext # Return 0
isFileExists() {
    local filePath="${1:-""}"

    local result=-1

    [[ -f "${filePath}" ]] && result=0

    return "${result}"
}

# isDirExists /tmp # Return 0
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

# isNotSet: test var to unset any value
# isNotSet $var # Return 1
# var="Any_value"
# isNotSet $var # Return 0
isNotSet() {
    local result=1

    #[[ -z "${@+"set"}" ]] && result=0
    [[ -z "${@+set}" ]] && result=0

    return "${result}"
}

# isSet: test var on set any value
# isSet $var # Return 1
# var="Any_value"
# isSet $var # Return 0
isSet() {
    local result=1

    [[ -z "${@+set}" ]] || result=0

    return "${result}"
}

# isLinux: test shell is linux or not
# isLinux # Return 0
isLinux() {
    local result=-1

    [[ "$(uname)" =~ Linux ]] && result=0

    return "${result}"
}

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
        msg "This script NOT have root mode."
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

# Check bash version
# bashCheck 4 # Return "Bash 4.0+ required." and exit if Bash version is liwer 4
bashCheck() {
    local version="${1:-4}"

    if [[ "$(isBashVersion "${version}")" != 0 ]]; then
        die "Bash "${version}".0+ required."
    fi
}

# Determine whether the current script was called as a library (for example, from another script) or if it was run directly
# isLibrary # Return 0 if is library # Return -1 if is executable script
isLibrary() {
    local result=-1

    (( "${#BASH_SOURCE[@]}" > 3 )) && {
        result=0
    }

    echo "${result}"
}

# Check if this code is called as a library
# libraryCheck # Return "Only source this as libraries." and exit if is library
libraryCheck() {
    (( "$(isLibrary)" == 0 )) || {
    die ""${BASH_SOURCE[0]}" Only source this as libraries."
    }
}

# Check for multiple inclusions, analogous to #pragma once or #ifndef MY_HEADER_H
# alreadySeen # Return 0 if called for the first time # Return 1 if called repeatedly
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

# isArray: The binary check of a variable on an array
# array=[1, 2, 3]
# isArray array # Return 0
isArray() {
    local result=1

    [[ "$(declare -p "${@}")" =~ "declare -a" ]] && result=0

    return "${result}"
}

# files=("file1.txt" "file2.txt" "file3.txt")
# getArrayIndexes array[@] # Return 0 1 2
getArrayIndexes() {
    declare -a array=("${!1}")

    local result=""

    result="${!array[*]}"

    echo "${result}"
    return "${result}"
}

# files=("file1.txt" "file2.txt" "file3.txt")
# getArrayLength array[@] # Return 3
getArrayLength() {
    declare -a array=("${!1:-""}")

    local result=0

    result=${#array[*]}

    echo "${result}"
    return "${result}"
}

# files=("file1.txt" "file2.txt" "file3.txt")
# operation="ls -l"
# forEach ls echo # Return 1/n1/n1/n
# forEach $operation files[@]
forEach() {
    local operation="${1:-echo}"
    local array="${2:-""}"

    if [[ -v "${array}" ]]; then
        array=("${!array}")
    else
        array=("${@}")
    fi

    for item in "${array[@]:0}"; do
        $operation "$item"
    done
}
