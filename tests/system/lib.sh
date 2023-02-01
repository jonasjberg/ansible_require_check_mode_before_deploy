#!/usr/bin/env bash
set -o errexit -o noclobber -o nounset -o pipefail


TESTLIB_GIT_TOPLEVEL_DIRPATH="$(git rev-parse --show-toplevel)"
readonly TESTLIB_GIT_TOPLEVEL_DIRPATH

if [ -n "${TERM:-}" ] && command -v tput &>/dev/null
then
    _bold="$(tput bold)" || _bold=''
    TESTLIB_COLOR_RED="$(tput setaf 1)${_bold}"
    TESTLIB_COLOR_GREEN="$(tput setaf 2)${_bold}"
    TESTLIB_COLOR_BLUE="$(tput setaf 4)${_bold}"
    TESTLIB_COLOR_BLUE_DIM="$(tput setaf 4)"
    TESTLIB_COLOR_CYAN="$(tput setaf 6)"
    TESTLIB_COLOR_RESET="$(tput sgr0)"
    unset _bold
else
    TESTLIB_COLOR_RED=''
    TESTLIB_COLOR_GREEN=''
    TESTLIB_COLOR_BLUE=''
    TESTLIB_COLOR_BLUE_DIM=''
    TESTLIB_COLOR_CYAN=''
    TESTLIB_COLOR_RESET=''
fi
readonly TESTLIB_COLOR_RED
readonly TESTLIB_COLOR_GREEN
readonly TESTLIB_COLOR_BLUE
readonly TESTLIB_COLOR_BLUE_DIM
readonly TESTLIB_COLOR_CYAN
readonly TESTLIB_COLOR_RESET


testlib::assert_exits_with_status()
{
    local _description="$1"
    shift
    local -i _expected_exitstatus="$1"
    shift
    # Sanity-check number of arguments must be two or greater; first being
    # correct exit status, remainder is the command to execute. Two shifts
    # done did ate some arguments, so ">= 2" becomes ">= 0" at this point.
    [ $# -gt 0 ] || testlib::on_internal_error

    # If description is (undefined or) empty string, create from command.
    [ -z "${_description:-}" ] && {
        printf -v _description 'Command "%s"' "$*"
    }
    printf '%sTEST:%s %s ...' \
        "$TESTLIB_COLOR_BLUE" "$TESTLIB_COLOR_RESET" "$_description"

    set +o errexit
    ( eval "$@" &>/dev/null ) >/dev/null
    local -i _actual_exitstatus=$?
    set -o errexit

    if (( _expected_exitstatus != _actual_exitstatus ))
    then
        printf ' %sFAIL!%s\n' "$TESTLIB_COLOR_RED" "$TESTLIB_COLOR_RESET"
        exit 66
    else
        printf ' %sPASS%s\n' "$TESTLIB_COLOR_GREEN" "$TESTLIB_COLOR_RESET"
    fi
}

testlib::assert_exits_successfully()
{
    local _description="$1"
    shift

    testlib::assert_exits_with_status "$_description" 0 "$@"
}

testlib::mark_testcase_begin()
{
    printf '%sEntered:%s %s\n' \
        "$TESTLIB_COLOR_CYAN" "$TESTLIB_COLOR_RESET" \
        "$(basename -- "${BASH_SOURCE[1]}")"
}

testlib::mark_testcase_end()
{
    printf '%sLeaving:%s %s\n' \
        "$TESTLIB_COLOR_CYAN" "$TESTLIB_COLOR_RESET" \
        "$(basename -- "${BASH_SOURCE[1]}")"
}

testlib::on_internal_error()
{
    printf '\nCRITICAL: Internal error in testing utilities! Aborting..\n' >&2
    exit 13
}
