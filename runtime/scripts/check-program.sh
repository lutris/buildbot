#!/bin/bash
#
# This script checks to make sure all library dependencies are in the runtime.
# If it returns no text output, you're good.

# The top level of the runtime tree
TOP=$(cd "${0%/*}/.." && echo ${PWD})

# Make sure we have something to run
if [ "$1" = "" ]; then
    echo "Usage: $0 executable [executable...]"
fi

STATUS=0
OUTPUT=`mktemp`
for OBJECT in "$@"; do
    "${TOP}/scripts/run.sh" ldd "${OBJECT}"\
        | grep -F -v "${TOP}" | grep -F "=>" | grep -E '/|not found' \
        | grep -F -v "libc." \
        | grep -F -v "libcrypt." \
        | grep -F -v "libdl." \
        | grep -F -v "libdrm." \
        | grep -F -v "libgcc_s." \
        | grep -F -v "libGL." \
        | grep -F -v "libglapi." \
        | grep -F -v "libm." \
        | grep -F -v "libnsl." \
        | grep -F -v "libpam." \
        | grep -F -v "libpthread." \
        | grep -F -v "librt." \
        | grep -F -v "libresolv." \
        | grep -F -v "libstdc++." \
        | grep -F -v "libutil." \
        | grep -F -v "libX11." \
        | grep -F -v "libX11-xcb." \
        | grep -F -v "libgobject-2." \
        | grep -F -v "libatk-1." \
        | grep -F -v "libgio-2." \
        | grep -F -v "libglib-2." \
        | grep -F -v "libgmodule-2." \
        >"${OUTPUT}"
    if [ -s "${OUTPUT}" ]; then
        echo "$1 depends on these libraries not in the runtime (excluding common system libs):"
        cat "${OUTPUT}"
        STATUS=1
    fi
done
rm -f "${OUTPUT}"

exit ${STATUS}

# vi: ts=4 sw=4 expandtab
