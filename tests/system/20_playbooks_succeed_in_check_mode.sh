#!/usr/bin/env bash
set -o errexit -o noclobber -o nounset -o pipefail

_SELF_DIRPATH="$(dirname -- "${BASH_SOURCE[0]}")"
source "${_SELF_DIRPATH}/lib.sh"


testlib::mark_testcase_begin


testlib::assert_exits_successfully 'Ansible run in check-mode succeeds' \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml --check ./tests/fixtures/playbooks/trivial.yml

testlib::assert_exits_successfully 'Ansible run in check-mode succeeds' \
    ansible-playbook -i ./tests/fixtures/inventories/local.yml --check ./tests/fixtures/playbooks/trivial_plus_ping_role.yml


testlib::mark_testcase_end
