#!/usr/bin/env bash

# s_utils_lib.sh
# 15.09.2024 [ru_RU]
# Boris Spiridonov
# Last Modified: 19.10.2025 11:40:31

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

printHelp() {
    cat <<EOF
Usage: $(basename "${0}") [-h]

#pragma once like wrapper for s_utils.sh.

Available options:

-h, --help      Print this help and exit.

Dependency:

s_utils.sh

EOF

    exit 0
}

bashCheck
libraryCheck
alreadySeen
