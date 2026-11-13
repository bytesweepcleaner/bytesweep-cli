# Hosts, transfer and sync

## Set up once

```sh
bsweep init                                          # writes bsweep.yml with every setting explained
bsweep host add office --address deploy@203.0.113.10
bsweep host test office
bsweep folder add site --host office --local /var/www/site --remote /srv/site \
  --direction both --delete never --ignore 'node_modules,*.log'
```

Settings live in `/etc/bytesweep/bsweep.yml` for root, or your user settings folder. Change them with
`bsweep host edit`, or edit the file. `host`, `folder` and `share` rewrite the file, so comments in it
are lost after the first change. Passwords are never stored: connections use your SSH keys.

## Copy

```sh
bsweep copy-to office ./site /srv/site        # here to the host
bsweep copy-from office /srv/report.csv .     # the host to here
```

The last argument is always a folder. Matching files are skipped, a dropped copy resumes, only changed
1 MB blocks are sent, and each file's hash is checked before it replaces anything. Links aren't followed.
A copy that doesn't fit stops before writing.

## Sync

```sh
bsweep sync site --preview    # show the changes
bsweep sync site              # show them and ask
bsweep sync site --yes        # for scripts
bsweep sync site --watch      # check every 5 seconds until stopped
sudo bsweep schedule sync site --every daily --at 02:00
```

| direction | Meaning |
|---|---|
| to-host | This machine decides |
| from-host | The host decides |
| both | Newer changes travel each way |

- With `delete: never`, nothing is ever removed. With `mirror`, removals are passed across and the file
  stays in `.bytesweep-sync-undo` in that folder for 7 days.
- If both sides changed a file, the host's version is kept as `name.conflict-DATE.ext` on both sides.
- A sync that would empty a folder, or remove over half of it, stops unless you add `--force`.
  `--watch` and schedules never force.

## Review a server from your computer

```sh
bsweep connect office
```

The full app runs on the server. Files go to Undo by default; Free now is a separate choice.

## Reach a laptop from a server

A server can't normally connect to a laptop, so the laptop connects out:

```sh
bsweep share add docs --path ~/Documents/work        # on the laptop
bsweep tunnel office --as my-laptop                  # on the laptop, runs until stopped
bsweep host add my-laptop --type laptop              # on the server, once
bsweep copy-from my-laptop docs/plan.pdf /srv/in     # on the server
```

The server reaches only folders under `share:`, read-only unless `writable: true`. Links can't lead out of
a share. Stopping the tunnel ends access. `sudo` commands find the tunnel of the person who ran sudo;
scheduled jobs running as root can't use a laptop tunnel.

## Who can do what

Transfers run as your SSH user, so they can only touch what that user can.

## Manage many servers

```sh
bsweep manage                 # every saved server, worst first
sudo bsweep monitor on        # a sample every 5 minutes, history and alerts
```

In `manage`: Space ticks, `a` selects all, `n` deselects all, `c` cleans safe items, `l` clears old logs,
`r` rescues, `m` opens live Monitor and Enter opens the full app. Actions on several servers need
passwordless sudo; otherwise press Enter and work on that server.

Set alert limits in `/etc/bytesweep/config.yml`:

```yaml
webhook: https://hooks.example.com/xxx
alerts:
  cpu: 90
  memory: 90
```

An alert fires when something changes, not every 5 minutes. A dead server can't report itself: use an
outside uptime check for that.
