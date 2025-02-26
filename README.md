# Bash-s_utils
A collection of syntactic sugar functions for Bash

# Usage
## As a interactively
add in to your ~/.bashrc
```bash
# S_utils
 if [ -f "${HOME}/Path/to/the/s_utils.sh" ]; then
   source "${HOME}/Path/to/the/s_utils.sh"
 fi
```

## As a Linrary
After the shebang, add at the beginning of your Bash Script
```bash
source s_utils_lib.sh
```
or
```bash
FILE="s_utils_lib.sh"

file_path="."
if [[ -f ""${file_path}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${file_path}:"* ]]; then
        PATH="${PATH}":"$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    fi
fi

file_path=""${HOME}""
if [[ -f ""${file_path}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${file_path}:"* ]]; then
        PATH="${PATH}":"${file_path}"
    fi
fi

file_path=""${HOME}"/Desktop"
if [[ -f ""${file_path}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${file_path}:"* ]]; then
        PATH="${PATH}":"${file_path}"
    fi
fi

file_path=""${HOME}"/another/folder/path/where/the/file/could/be_located"
if [[ -f ""${file_path}"/"${FILE}"" ]]; then
    if [[ ":${PATH}:" != *":${file_path}:"* ]]; then
        PATH="${PATH}":"${file_path}"
    fi
fi

source "${FILE}" || (echo >&2 -e ""${FILE}" not finde in the \$PATH." && exit 1)
```
