#!/usr/bin/env bash
set -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


testlib::assert_exits_successfully 'simple command exits successfully' echo sanity checking ..
testlib::assert_exits_successfully '' echo meoooww
testlib::assert_exits_with_status 'non-zero exitcode result fails' 1 false


testlib::mark_testcase_end
