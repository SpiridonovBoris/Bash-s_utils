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
```
