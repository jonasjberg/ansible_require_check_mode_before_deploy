# -*- coding: utf-8 -*-
# Copyright (c) 2023, Jonas Sjöberg <jonas@jonasjberg.com>

import json
import os
import pprint
import re
import subprocess

from ansible.module_utils.six import string_types
from ansible.plugins.action import ActionBase


_DEFAULT_RUN_HISTORY_FILEPATH = '~/.ansible_check_mode_history.json'


def get_current_git_revision():
    try:
        stdout = subprocess.check_output(
            ['git', 'rev-parse', 'HEAD']
        ).decode('utf8').strip()
    except subprocess.CalledProcessError as exc:
        return None

    if not re.match('^[0-9a-f]{40}$', stdout):
        return None

    return stdout


class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        result = super(ActionModule, self).run(tmp, task_vars)

        # The playbook argument can be anything, does not have to be a playbook
        # or even an existing file. What matters is that it is some unique
        # reference that sort of "namespaces" the Git revision checks.
        # Normally, you probably will pass the name of the playbook that uses
        # this module, but that is besides the point.
        playbook = self._task.args.get('playbook')
        if (
                not playbook
                or not isinstance(playbook, string_types)
                or not playbook.strip()
        ):
            result['failed'] = True
            result['msg'] = 'Required option "playbook" is undefined or empty'
            return result

        current_revision = get_current_git_revision()
        if current_revision is None:
            result['failed'] = True
            result['msg'] = 'Unable to retrieve Git revision'
            return result

        run_history_data = {}
        run_history_filepath = os.path.normpath(os.path.expanduser(
            os.getenv('ANSIBLE_CHECK_HISTORY_FILE', _DEFAULT_RUN_HISTORY_FILEPATH)
        ))
        if os.path.isfile(run_history_filepath):
            with open(run_history_filepath, 'r', encoding='utf8') as filehandle:
                try:
                    run_history_data = json.load(filehandle)
                except json.decoder.JSONDecodeError as exc:
                    # TODO(jonas): Error handling and such..
                    pass

        # Expected persisted "run history" JSON structure:
        #
        #     run_history_data = {
        #         'trivial.yml': [
        #             '29564db96bb0d7cea9da16ef918d2ba8793ab98f',
        #         ],
        #     }
        #
        # TODO(jonas): Add version number to serialized data.
        assert isinstance(run_history_data, dict)
        if run_history_data:
            assert all(isinstance(key, string_types) for key in run_history_data)
            assert all(isinstance(value, list) for value in run_history_data.values())
            assert all(
                isinstance(revision, string_types)
                for value in run_history_data.values()
                for revision in value
            )

        running_in_check_mode = bool(self._task.check_mode)
        if running_in_check_mode:
            persisted_history_needs_refresh = False

            if playbook not in run_history_data:
                run_history_data[playbook] = [current_revision]
                result['msg'] = f'First entry for {playbook} revision {current_revision}'
                persisted_history_needs_refresh = True
            elif current_revision not in run_history_data[playbook]:
                run_history_data[playbook].append(current_revision)
                result['msg'] = f'Added {playbook} revision {current_revision}'
                persisted_history_needs_refresh = True

            if persisted_history_needs_refresh:
                with open(run_history_filepath, 'w', encoding='utf8') as filehandle:
                    json.dump(run_history_data, filehandle, ensure_ascii=True, indent=4, sort_keys=True)

            return result

        # Not running in check-mode at this point.
        if current_revision not in run_history_data.get(playbook, []):
            result['failed'] = True
            result['msg'] = f'Playbook {playbook} has not been run in check-mode'

        return result
