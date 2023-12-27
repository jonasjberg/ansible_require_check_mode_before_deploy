#!/usr/bin/env bash
set -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


testlib::assert_exits_successfully 'Ansible is installed' command -v ansible
testlib::assert_exits_successfully 'Git is installed' command -v git
testlib::assert_exits_successfully 'Python is installed' command -v python3

testlib::assert_exits_successfully 'Ansible version command succeeds' \
    ansible-playbook --version


testlib::mark_testcase_end
