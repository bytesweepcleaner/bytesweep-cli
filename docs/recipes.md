# Recipes

## Cron: alert a chat channel

```cron
*/15 * * * * root /usr/local/bin/bsweep check --warn 85 --crit 95 --webhook https://hooks.example.com/xxx
```

`check` exits 0 ok, 1 warning, 2 critical, so it also works as a Nagios or Icinga check.

## Ansible: install and report

```yaml
- hosts: all
  become: true
  tasks:
    - name: Install ByteSweep CLI
      ansible.builtin.copy:
        src: bsweep-linux-{{ ansible_architecture }}
        dest: /usr/local/bin/bsweep
        mode: "0755"
    - name: Check disks
      ansible.builtin.command: bsweep check
      register: disks
      changed_when: false
      failed_when: disks.rc > 1
    - name: Show problems
      ansible.builtin.debug:
        var: disks.stdout_lines
```

## Ansible: clean safe items

```yaml
- hosts: all
  become: true
  tasks:
    - ansible.builtin.command: bsweep clean --safe --yes
```

## Many servers from your laptop

```sh
bsweep fleet --file hosts          # table, worst first; exit 2 if any server is in trouble
bsweep fleet --json web1 web2 db1
```

Needs SSH keys. Hosts without bsweep get a copy piped to /dev/shm, run once, then removed.
Same CPU type only. Looking is free on every host.

## Clean by itself

```sh
sudo bsweep auto on --when 90 --webhook https://hooks.example.com/xxx
```

Every 15 minutes, safe steps only. Never logs, Undo, images, volumes or databases.

## CI: clean a self-hosted runner before a job

```yaml
- name: Make room
  run: sudo bsweep ci --min-free 10G --images
```

Exit 0 means there is room. Exit 1 fails the job with a clear reason, and on GitHub Actions it
shows as an error annotation. `--images` also removes unused images and stopped containers.

## Prometheus

```cron
*/5 * * * * root /usr/local/bin/bsweep metrics --out /var/lib/node_exporter/textfile_collector/bytesweep.prom
```

## Config file

```yaml
# /etc/bytesweep/config.yml
warn: 80
crit: 92
webhook: https://hooks.example.com/xxx
target: 2G
keep:
  - /var/log/audit
  - /srv/exports
```

Paths under `keep` are never cleaned, by any command, the app or automatic cleanup. An unknown
key stops the run, so a typo can't silently leave a folder unprotected.

## Clear logs on a schedule

```sh
sudo bsweep schedule logs --every weekly --day sun --at 03:00 --older 7d
sudo bsweep schedule logs --every daily --at 02:30 --older 3d --docker --live --webhook https://hooks.example.com/xxx
sudo bsweep schedule list
sudo bsweep schedule remove s1
```

The journal and rotated logs older than `--older` are cleared. `--docker` empties container logs
over 50 MB and `--live` empties live logs over 1 GB; both lose recent history, so they're opt-in.
A run missed while the server was off happens at next boot. Paths under `keep` are skipped.
