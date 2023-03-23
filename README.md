# This is not the project you want
_TODO(jonas): ....._

I spent ~2 hours trying to make ChatGPT write this for me. It came close but no
cigar, threw this project together in 30 minutes. Actually somewhat useful so
might revisit and clean up; but ... prematurely publicizing just so that I can
easily share it to a couple of folks..


## Example Usage
Example playbook `playbooks/foobar_servers.yml`:
```yaml
- name: Example playbook that verifies that each unique Git revision of the
        project runs in check-mode ("--check") at least once before actually
        deploying state to targeted hosts
  hosts: foobar_servers
  tasks:
    - name: Require check-mode prior to deploy
      require_check_mode_before_deploy:
        playbook: playbooks/foobar_servers.yml
```

It does not matter how or when the module runs but it likely makes most sense
to run it first in the playbook, alongside any other pre-flight sanity-checks.
The module runs locally regardless of the play hosts selection.


## Running Tests
Run all tests:
```
./tests/run_all_tests.sh
```


## Authors
* Jonas Sjöberg <jonas@jonasjberg.com>


## Licensing
*Do What The Fuck You Want To Public License*, Version 2.
Refer to `LICENSE_WTFPL.txt` and <http://www.wtfpl.net/>.
