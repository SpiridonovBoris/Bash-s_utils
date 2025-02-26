#!/usr/bin/env bash

# s_utils_lib.sh
# 16.09.2024 [ru_RU]
# Boris Spiridonov
# Last Modified: 16.09.2024 15:18:15

# Bash utils library
# For only be evaluated a single time
# Usage

# Add library
FILE="s_utils.sh"

filePath="."
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${PATH}":"$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    fi
fi

filePath=""${HOME}""
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${PATH}":"${filePath}"
    fi
fi

filePath=""${HOME}"/Desktop"
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${PATH}":"${filePath}"
    fi
fi

filePath=""${HOME}"/Job/Ronavi/Projects/H1500/Prog"
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${PATH}":"${filePath}"
    fi
fi

source "${FILE}" || (echo >&2 -e ""${FILE}" not finde in the \$PATH." && exit 1)

bashCheck
libraryCheck
alreadySeen
