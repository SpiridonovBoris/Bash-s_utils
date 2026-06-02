# Bash-sUtils
A collection of syntactic sugar functions for Bash

# Usage
## As a interactively
Add the following line to your ~/.bashrc:
```bash
# sUtils
 if [ -f "${HOME}/Path/to/the/sUtils.sh" ]; then
   source "${HOME}/Path/to/the/sUtils.sh"
 fi
```

## As a Library
After the shebang, add the following line at the beginning of your Bash script:
```bash
source sUtilsLib.sh
```
or
```bash
FILE="sUtils.sh"

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
