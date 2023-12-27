#!/usr/bin/env bash
set -o errexit -o noclobber -o nounset -o pipefail


if ! command git rev-parse --is-inside-work-tree &> /dev/null
then
    command cat >&2 <<EOF

ERROR: Unable to find a reference working directory when
       executed from outside of the Git repository root.
EOF
    exit 13
fi

if ! pushd -- "$(command git rev-parse --show-toplevel)" > /dev/null
then
    builtin printf 'CRITICAL: This is a BUG!\n' >&2
    exit 70
fi
trap 'popd > /dev/null' EXIT


declare -i exitstatus=0

command find ./tests/system/ -type f -name '*.sh' -print0 |
command sort --zero-terminated |
while IFS=$'\0' read -r -d '' filepath
do
    # BSD/MacOS find does not support the '-executable' option..
    [ -x "$filepath" ] || continue

    # Run presumed "test suite" script.
    "$filepath" || exitstatus=13
done


if (( exitstatus != 0 ))
then
    builtin printf '\nSUMMARY RESULT: FAILURE!\n One or more test(s) failed :(\n' >&2
else
    builtin printf '\nSUMMARY RESULT: GREAT SUCCESS!\n'
fi

exit "$exitstatus"
