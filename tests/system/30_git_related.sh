#!/usr/bin/env bash
set -o errexit -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


testlib::assert_exits_successfully 'Sanity-check Git is available' \
    command -v git

testlib::assert_exits_successfully 'Sanity-check variable set in lib.sh' \
    '[ -d "$TESTLIB_GIT_TOPLEVEL_DIRPATH" ]'

__temp_dirpath="$(mktemp -d -t ansible_toolchain_tests.XXXXXX)"
testlib::assert_exits_successfully 'Created temporary directory' '[ -d "$__temp_dirpath" ]'

testlib::assert_exits_successfully 'Sample playbook to be copied exists' \
    '[ -f "${_SELF_DIRPATH}/30_playbook_not_in_git.yml" ]'

testlib::assert_exits_successfully 'Copy sample playbook to temporary directory' \
    command cp -nv -- "${_SELF_DIRPATH}/30_playbook_not_in_git.yml" "$__temp_dirpath"

testlib::assert_exits_successfully 'Copy plugins to temporary directory' \
    command cp -rnv -- "${TESTLIB_GIT_TOPLEVEL_DIRPATH}/plugins" "$__temp_dirpath"

testlib::assert_exits_successfully 'Copy ansible.cfg to temporary directory' \
    command cp -nv -- "${TESTLIB_GIT_TOPLEVEL_DIRPATH}/ansible.cfg" "$__temp_dirpath"

testlib::assert_exits_successfully '' '
    cd "$__temp_dirpath"
    ansible-playbook -i localhost, 30_playbook_not_in_git.yml
'


testlib::mark_testcase_end
