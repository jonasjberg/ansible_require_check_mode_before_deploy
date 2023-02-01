#!/usr/bin/env bash
set -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


testlib::assert_exits_successfully '' echo sanity checking ..
testlib::assert_exits_with_status '' 1 echo sanity checking ..

testlib::assert_exits_successfully 'simple command should exit successfully' \
    echo sanity checking ..

testlib::assert_exits_with_status 'simple command returning non-zero should fail' 1 \
    false

testlib::assert_exits_successfully 'ansible-playbook --version exits successfully' \
    ansible-playbook --version


testlib::mark_testcase_end
