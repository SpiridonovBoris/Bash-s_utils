#!/usr/bin/env bash

# s_utils_lib.sh
# 16.09.2024 [ru_RU]
# Boris Spiridonov
# Last Modified: 14.04.2025 13:15:47

# Bash utils library
# For only be evaluated a single time
# Usage

# Add library
FILE="s_utils.sh"

file_path=""${HOME}"/.local/lib/bash"
if [[ -f ""${file_path}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${file_path}:"* ]]; then
        PATH="${file_path}":"${PATH}"
    fi
fi

filePath=""${HOME}"/Desktop"
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${filePath}":"${PATH}"
    fi
fi

filePath=""${HOME}""
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${filePath}":"${PATH}"
    fi
fi

filePath="."
filePath="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [[ -f ""${filePath}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${filePath}:"* ]]; then
        PATH="${filePath}":"${PATH}"
    fi
fi

source "${FILE}" || (echo >&2 -e ""${FILE}" not finde in the \$PATH." && exit 1)

bashCheck
libraryCheck
alreadySeen
