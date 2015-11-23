#!/bin/bash
#
# Make sure the runtime has all necessary runtime dependencies

# The top level of the runtime tree
TOP=$(cd "${0%/*}/.." && echo ${PWD})

if [ "$1" ]; then
    CHECK_PATH="$1"
else
    CHECK_PATH="${TOP}"
fi
echo $CHECK_PATH
STATUS=0

for FOLDER in "lib32" "lib64" "steam/amd64/lib/x86_64-linux-gnu" \
"steam/amd64/lib" "steam/amd64/usr/lib/x86_64-linux-gnu" "steam/amd64/usr/lib" \
"steam/i386/lib/i386-linux-gnu" "steam/i386/lib" \
"steam/i386/usr/lib/i386-linux-gnu" "steam/i386/usr/lib"
do
    find "${CHECK_PATH}/${FOLDER}" -type f | grep -v 'ld.*so' | \
    while read file; do
        if ! (file "${file}" | fgrep " ELF " >/dev/null); then
            continue
        fi

        echo "Checking ${file}"
        if ! "${TOP}/scripts/check-program.sh" "${file}"; then
            STATUS=1
        fi
    done
done
exit ${STATUS}

# vi: ts=4 sw=4 expandtab
