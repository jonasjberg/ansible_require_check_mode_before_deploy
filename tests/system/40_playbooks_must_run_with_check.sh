#!/usr/bin/env bash
set -o errexit -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


__temp_filepath="$(mktemp -t ansible_toolchain_tests.XXXXXX)"
testlib::assert_exits_successfully 'Created temporary file' '[ -f "$__temp_filepath" ]'
testlib::assert_exits_successfully 'Temporary file is empty' '[ ! -s "$__temp_filepath" ]'

ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE="$__temp_filepath"
export ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE
testlib::assert_exits_successfully 'History file exists' '[ -f "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'
testlib::assert_exits_successfully 'History file is empty' '[ ! -s "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'

testlib::assert_exits_with_status 'Ansible run fails since playbook never ran in check-mode' \
    2 \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml ./tests/fixtures/playbooks/trivial.yml

testlib::assert_exits_with_status 'Ansible run with --check succeeds' \
    0 \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml ./tests/fixtures/playbooks/trivial.yml --check

testlib::assert_exits_successfully 'History file exists' '[ -f "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'
testlib::assert_exits_successfully 'History file should no longer be empty' '[ -s "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'
testlib::assert_exits_successfully 'History file contains first playbook' grep -F trivial.yml "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE"

testlib::assert_exits_with_status 'Ansible run fails since second playbook never ran in check-mode' \
    2 \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml ./tests/fixtures/playbooks/trivial_plus_ping_role.yml

testlib::assert_exits_with_status 'Ansible run of second playbook with --check succeeds' \
    0 \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml ./tests/fixtures/playbooks/trivial_plus_ping_role.yml --check

testlib::assert_exits_successfully 'History file exists' '[ -f "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'
testlib::assert_exits_successfully 'History file is not empty' '[ -s "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE" ]'
testlib::assert_exits_successfully 'History file contains second playbook' grep -F trivial_plus_ping_role.yml "$ANSIBLE_CHECK_MODE_RUNS_HISTORY_FILE"


testlib::mark_testcase_end
