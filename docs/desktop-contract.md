# Desktop contract: how the ByteSweep apps drive `bsweep` over SSH

Contract **1** (`bsweep version --json` says `"contract": 1`). Branch `server-tui`, 6 November 2026; maintenance and explained problems added 9 November.
Every example output is a real capture in [`desktop-json/`](desktop-json/) (one file per command
line; [`desktop-json/_index.tsv`](desktop-json/_index.tsv) gives each file's exact command line,
exit code and first stderr line). Copy them as test fixtures; don't hand-edit them.

## Fixtures

The fixtures were captured on a test Linux server seeded with problems on purpose: old and
rotated logs, a large old archive, duplicate photos, a crash dump, failing and missing cron jobs,
a failing service, dev servers on ports 3000 and 3001, an nginx site whose folder is missing,
MariaDB with the general query log on, PostgreSQL with an unused replication slot, a backup disk
for `archive`, and folders for organize, rename, convert and tidy.

## How to call

    ssh HOST 'sudo -n bsweep CMD ARGS --json'

If that exits 1 with sudo's "a password is required" on stderr (sudo's own exit, not bsweep's,
so check stderr), run `bsweep CMD ARGS --json` without sudo: looks still work, changes exit 5.

- **stdout is one JSON value** (object or array) and a newline, nothing else, on every exit code.
  Two streams are the exception: `live --json` (one object a line until the desktop hangs up)
  and `stats --stream`. For one sample use `live --json --count 1` or `stats --json`.
- **stderr is for people**: errors, hints, notes. Show it, never parse it. A preview never
  prints its question to stdout.
- **Lists are `[]`, maps `{}`, never `null`**, at any depth. Fields marked omitempty in Go
  are left out when empty; treat a missing field as empty/false/0.
- **Sizes are bytes** (int64). **Percent** is a 0 to 100 float. **Times** are RFC 3339 with the
  server's offset. `"0001-01-01T00:00:00Z"` means unknown or never (jobs' `lastRun`, sites'
  `certificateEnds` when there is no certificate).
- Unknown fields must be ignored: fields are added without a contract bump.
- Quote paths and names for the remote shell (single quotes, `'\''` for a quote inside).
- Times out: looks are quick except `health`, `report`, `dupes`, `apps` and `updates`
  (`updates` refreshes the package lists first: allow 2 minutes).

## Preview, then confirm

Every command that changes something works in two calls:

1. `bsweep CMD ARGS --json` (no `--yes`): **nothing changes**. The answer is a preview with
   `"dryRun": true` at the top.
2. Show it; when the person agrees: `bsweep CMD ARGS --json --yes`. The answer has no `dryRun`.

`--dry-run --json` is the same as step 1. Send exactly the same ARGS both times. Some
previews can be empty (`items: []`); a `--yes` with nothing to do answers like a run that did
nothing (`cleaned: []`, `freed: 0`).

Exceptions, which run at once because there is nothing to preview: `advanced on|off` (a display setting), `alerts test` (sends one test message),
`before` (writes down the current state, changes nothing on the system). `rescue` without a full
disk answers `{"needed": false}` and does nothing.

## Exit codes

| Code | Meaning | stdout | Desktop does |
|---|---|---|---|
| 0 | fine / done | JSON | show it |
| 1 | warning, or ran but fell short (`rescue` didn't reach its target, `after` found something worse) | JSON | show it, amber |
| 2 | critical: `why`, `check`, `health`, `drives`, `sites`, `jobs`, `logins`, `sharesafe`, `databases` found something bad | JSON | show it, red |
| 3 | error: bad usage, not found, refused, or it failed | usually empty; a run that partly failed still prints its JSON with `failed` | show stderr |
| 4 | not used since 1.0.1; from a 1.0.0 server it meant "needs a licence" | empty, or `{"error": "trial-ended", ...}` | say the server has an older ByteSweep CLI: `sudo bsweep update` there (Free section) |
| 5 | needs root and has none | empty | say: give this user sudo (NOPASSWD for bsweep), or log in as root |

Looks with 1 and 2 always print their full JSON first; the code is extra. Previews never need root where the system lets anyone look; `--yes` needs root for changes to the system (exit 5).

## First call: `version --json`

    sudo -n bsweep version --json          version.json, version.nosudo.json

| Field | |
|---|---|
| `version` | bsweep's version (`1.1.0-test+<commit>` on the test server) |
| `contract` | this document's number; refuse to drive a server with a higher major than you know |
| `os`, `arch` | Go names: `linux`, `darwin`, `freebsd`, `windows`; `amd64`, `arm64`, ... |
| `distro` | `/etc/os-release` PRETTY_NAME on Linux, else "" |
| `host`, `user` | hostname, and the user bsweep runs as (`root` under sudo) |
| `root` | runs with root/administrator rights |
| `free` | `true` from 1.0.1 (Free section); missing on 1.0.0 |
| `licence` | `{"licensed": true, "free": true, "key": "not needed"}` from 1.0.1, for the 3.3 desktop apps |
| `json` | sorted names of every command that answers in JSON |

A bsweep older than this contract has no `version --json`: it prints just the version on
stdout (not JSON) and exits 0. Treat "not JSON" or a missing command in `json` as: "This server
has an older ByteSweep CLI: update it (`sudo bsweep update`)".

## Free (1.0.1, 12 November 2026)

ByteSweep CLI is free and open source from 1.0.1: no licence, no key, no trial, on any number
of machines. What changed for the desktop apps:

- `version --json` has `"free": true` and `"licence": {"licensed": true, "free": true, "key": "not needed"}`, and no
  `trial`. `summary --json`, `fleet status` and `fleet run` hosts keep `"licensed": true`, always:
  the 3.3 desktop apps read it and offer a key box when it is false or missing. `slots` and
  `trial` are gone.
- Exit 4 is no longer used. A server still on 1.0.0 may answer exit 4, or
  `{"error": "trial-ended"}`: say "This server has an older ByteSweep CLI: update it
  (`sudo bsweep update`)", never offer a licence box.
- `licence`, `activate` and `deactivate` still exist so old callers get an answer (`deactivate --json`
  without `--yes` adds `"dryRun": true`, a preview as before): they change
  nothing, exit 0, and with `--json` print `{"licensed": true, "free": true, "key": "not needed"}`. Don't call them.
- Remove every licence box, "trial ended" state, Buy link and "no licence" badge from the
  Servers screens. Changes still need root on that server (exit 5), as before.

## Overview of a server

| Command line | Fixture | Fields |
|---|---|---|
| `summary --json` | summary.json | `host`; `disks[]` {`path`, `pct`, `inodePct`, `free`, `total`}; `safe` (bytes the safe rules can free); `bad`, `warn` (health counts); `problems[]` (titles of bad findings); `licensed` (always true from 1.0.1); `now` (one quick stats sample, below); `updates` {`total`, `security`, `restartNeeded`, `checked` RFC 3339 or ""} from the last updates check, never a fresh one; `findings[]` (the warn and bad health findings, as `health`); `forecast` {`path`, `daysLeft`, `fullOn`, `confidence`} or `{}` (the disk that fills first, see "Disk full in N days"). Quick on purpose: the server list's row |
| `why --json` | why.json | the fullest disk: `disk`, `pct`, `inodePct`, `free`, `total`, `reasons[]` (sentences), `next` (sentence with the next command). Exit 1/2 at the warn/crit limits |
| `health --json` | health.json | list of {`id`, `area`, `level` ok/warn/bad, `title`, `fix`?, `seeWhy`?, `about`, `risk`, `steps[]`, `action`?}. `fix` is text to show, never run; `action` is what bsweep can run (see "Problems explained" below) |
| `check --json` | check.json | `status` ok/warning/critical; `alerts[]` {`mount`, `kind` space/inodes, `pct`, `critical`}; `drives[]` (failing or worn, as drives); `newKeys[]` (SSH keys added since `logins accept`, as logins keys) |
| `drives --json` | drives.json | `drives[]` {`device`, `model`, `size`, `kind`, `state` Healthy/Worn/Failing/Unknown, `note`, ...}; `note` |
| `report --json` | report.json | everything: `mounts[]` (Go names: `Path`, `Source`, `Type`, `Total`, `Used`, `Avail`, `Reserved`, `InodesTotal`, `InodesUsed`), `items[]` (as clean), `held[]` (deleted files still open), `health[]`. Feed two to `diff` |
| `diff A.json B.json --json` | diff.json | paths on the server; `disks[]`, `newItems[]`, `goneItems[]`, `newProblems[]`, `fixedProblems[]` (sentences). Exit 1 with new problems |
| `grown --json --days N` | grown.json | `since`; `grew[]` {`path`, `delta`}. Needs the daily record (`timer on`); empty until then |
| `log --since 30d --json` (or `history`) | log.json | ByteSweep's own record of changes: {`time`, `user`, `action`, `what`, `freed`, `error`?} |
| `config --json`, `config check --json` | config.json, config.check.json | `warn`, `crit`, `alerts` {`cpu`, `memory`}, `webhook`?, `target`?, `keep[]`? (paths never cleaned); check: `{"valid": true, "path"}`, a broken file exits 3 |
| `fleet HOST... --json` | fleet.json | addresses not saved in bsweep.yml (for saved servers see "Fleet" below), run from one server about others over its own SSH: {`host`, `disk`, `pct`, `inodePct`, `canFree`, `bad`, `warn`, `top`, `error`?}. The desktop normally doesn't need this |

## Live

| Command line | Fixture | Fields |
|---|---|---|
| `stats --json` | stats.json | `t`, `cpu` (percent), `memUsed`, `memTotal`, `swapUsed`, `swapTotal`, `load`, `netRx`, `netTx` (bytes/s), `cores[]` (percent each), `top[]` {`pid`, `name`, `cpu`, `rss`}; `diskRead`, `diskWrite` when known |
| `stats --detail --json` | stats.detail.json | adds `loads` [1, 5, 15 min], `memory[]` {`name`, `bytes`, `bar`?, `of`?}, `tiers[]`?, `coreKinds[]`? |
| `live --json --count 1 [--detail]` | live.json, live.detail.json | one sample as stats, without `top`; `--every 2s` sets the gap. Without `--count` it streams one line per sample |
| `stats --history --json [--since 24h\|7d\|30d] [--points 300]` | stats.history.json, stats.history.since.json | an object (was a bare list): `recording`, `since`, `every` (seconds between points), `samples[]` {`t`, `cpu`, `memUsed`, `memTotal`, `swapUsed`, `swapTotal`, `load`, `disks[]` {`path`, `used`, `total`}}, averaged down to at most `--points` (disks: the last value in each bucket). `recording: false` and `samples: []` when the monitor is off. Kept 30 days |
| `monitor on --json` → `--yes` | monitor.on.preview, monitor.on.done | preview `dryRun`, `about`, `recording` → `{"recording": true}`; `monitor off` the same. "Start recording" in the desktop |
| `advanced --json`, `advanced on --json`, `advanced off --json` | advanced*.json | `{"advanced": bool, "path"}`: saved per user (root's under sudo) |

## Looks for the server's own problems

All give more with sudo.

| Command line | Fixture | Fields |
|---|---|---|
| `databases --json [--all]` | databases.json | `engines[]` {`id` mysql/postgresql/mongodb/redis, `name`, `dataDir`, `bytes`, `disk`, `diskSize`, `asked` (bsweep could ask the server itself), `parts[]` {`kind` (binlogs, wal, general-log, slow-log, temp, server-logs, ...), `name`, `path`, `bytes`, `files`, `oldest`}, `databases[]` {`name`, `bytes`, `system`?}, `findings[]` {`level`, `title`, `fix`?, `note`?}}. Fixes are shown, never run by bsweep |
| `sites --json [--problems]` | sites.json | `webServers[]`; `sites[]` {`server`, `names[]`, `listen[]`, `root`, `rootGone`, `logs[]` {`path`, `bytes`, `rotated`}, `certificateEnds`, `config` (file:line), `findings[]`}; `webServerFindings[]`? |
| `jobs --json [--all]` | jobs.json | `jobs[]` {`kind` cron/timer, `name`, `user`, `when`, `command`, `lastRun`, `nextRun`, `shouldHaveRun`, `state` ok/failed/missed/gone/unheard/unknown, `says`, `seeWhy`?, `setIn`, `switchedOff`?} |
| `logins --json [--days 7]` | logins.json | `days`, `logRead`, `logFrom`, `logins[]` {`user`, `times`, `from[]`, `methods[]`, `last`, `keys[]`}, `failedTries`, `sources[]` (who keeps guessing), `keys[]` {`account`, `file`, `line`, `type`, `fingerprint`, `comment`, `fileChanged`, `new`}, `firstLook`, `haveKnownList` |
| `sharesafe --json` | sharesafe.json | `system`, `risk`, `firewall`, `localOnly`, `items[]` {`group`, `id`, `name`, `state`, `risk` low/medium/high, `who`, `says`, `fix`, `seen`, `ports[]`, `openToNetwork`, `program`}. SSH and firewall fixes are advice only |
| `ports --json [--open]` | ports.json | {`port`, `address`, `openToNetwork`, `pid`, `program`, `user`, `started`, `cpu`, `memory`, `command`, `folder`, `project`?, `devServer`?, `container`?, `image`?, `service`?, `neverStopped`?} |
| `startup --json [--failed] [--all]` | startup.json | {`id` (pass to off/on), `name`, `group`, `kind`, `runs`, `maker`, `on`, `failed`?, `lastStart`, `needsAdmin`, `path`, `seeWhy`?}; notes about what couldn't be read go to stderr |
| `updates --json [--security]` | updates.json | `tools[]`, `updates[]` {`manager`, `name`, `from`, `to`, `source`, `security`}, `security` (count), `restart` {`needed`, `packages[]`, `services[]`, `atNextRestart[]`, `command`}, `locks[]`, `refreshed` |
| `sleep --json` | sleep.json | wakes and what keeps it awake; a server that never sleeps says so |
| `apps --json` | apps.json | {`id` (pass to remove), `name`, `version`, `source`, `size`, `kept`? (why it is never removed)} |
| `apps leftovers --json` | apps.leftovers.json | {`id`, ...} for `apps leftovers clean ID` |
| `before --list --json` | before.list.json | names of saved records |
| `after --json [--name N]` | after.json | `since`, `name`, `servicesStopped[]`, `servicesStarted[]`, `servicesNowFailed[]`, `servicesNoLongerFailed[]`, `portsClosed[]`, `portsOpened[]`, `packagesChanged[]` ("name 1.0 → 1.1"), `packagesAdded[]`, `packagesRemoved[]`, `kernel`?, `disks[]`?, `restartWaiting`, `restartWaitedBefore`. Exit 1 when worse |
| `before --json [--name N]` | before.json | writes the record and returns it (`packages` is a map name → version) |

## Files and space

| Command line | Fixture | Fields |
|---|---|---|
| `top PATH --dirs 20 --files 20 --json [--inodes]` | top.json | {`path`, `size`, `inodes`}: folders first, then files of 4 MB or more |
| `find PATH --larger 10M --older 30d --newer 12h --name '*.gz' --json` | find.json | {`path`, `size`, `modified`} |
| `dupes PATH... --json [--min 1M] [--all-disks]` | dupes.json | `groups[]` {`id`, `folder`, `size` (one copy), `files`?, `copies[]` {`path`, `modified`, `sameFileAs`?}, `save`}, `filesLooked`, `skipped[]` |
| `clean --list --json [--group G] [--older 90d]` | clean.list.json | {`id`, `group`, `title`, `why`, `size`, `level` safe/review/manual, `command` (what it runs, words), `where`, `lastUsed`?, `undo`?, `oneByOne`?}. Groups: quick system logs dev ai containers web chats privacy databases snapshots |
| `logs --json` | logs.json | the log targets, as clean items (level `review` for live/container logs, which need `--live`/`--docker`) |
| `undo --json` | undo.json | {`id`, `original`, `size`, `cleaned`}; entries end after 7 days |
| `archive list --json`, `archive where NAME --json` | archive.list.json | {`id`, `original`, `host`, `archived`, `size`, `files`, `dir`, `target`, `onDisk`, `disk` {`mount`, `source`, `uuid`, `label`}, `freed`, `connected`, `nowAt`?} |

## Changes (preview, then `--yes`)

| Command line (add `--yes` to run) | Preview fixture | Done fixture | Preview fields → done fields |
|---|---|---|---|
| `clean ID... --json`, `clean --safe --json`, `clean --group G --older 30d --json`, `+ --now` | clean.ids.preview, clean.safe.preview, clean.group-older.preview, clean.now.preview | clean.ids.done, clean.safe.done | `items[]` (clean items), `undo` → `cleaned[]` (ids), `failed[]`, `freed` (df's view), `undo` |
| `rm PATH... --json [--now]` | rm.preview, rm.now.preview | rm.done | `items[]` {`path`, `size`, `openBy`?}, `total`, `undo` → same + `failed[]`. A protected path exits 3 |
| `undo restore ID --json` | undo.restore.preview | undo.restore.done | `action`, `entry` → the entry |
| `undo free ID --json` | undo.free.preview | | `action`, `entry` → the entry; it can't be put back after |
| `undo free --all --json`, `--older 3d` | undo.free.all.preview | | `items[]`, `total`, `undo: false` → `freed`, `items[]`, `failed[]` |
| `rescue --json [--disk /] [--target 2G] [--hard]` | rescue.preview (`needed: false`), rescue.disk.preview, rescue.hard.preview | rescue.done | `disk`, `target`, `steps[]` {`title`, `command`, `size`, `hard`} → `disk`, `target`, `before`, `after` (free bytes), `reached`, `failed[]`, `stopped[]` (failed services to restart by hand). Exit 1 when the target isn't reached. Hard steps (old kernels, old logs, Undo) run only with `--hard` |
| `logs clear --older 7d --json [--docker] [--live]` | logs.clear.preview, logs.clear.all.preview | logs.clear.done | `items[]`, `total` → `freed`, `failed[]`. Can't be undone |
| `dupes PATH --keep newest\|oldest\|shortest --json [--now]` | dupes.keep.preview | dupes.keep.done | `keep`, `items[]` {`path`, `keep`, `size`}, `freed`, `undo` → `cleaned[]`, `failed[]`, `freed`, `undo`. One copy of each always stays |
| `compress PATH... --older 30d --json [--now]` | compress.preview | compress.done | `items[]` {`path`, `size`, `kind`, `expectedSize`, `modified`}, `size`, `expectedSaving`, `undo` → `compressed[]`, `size`, `compressedSize`, `failed[]`, `undo` |
| `archive PATH... --to DIR --json` | archive.preview | archive.done | `to`, `items[]` {`path`, `size`, `files`, `dir`, `refused`? (why not)}, `total` → `archived[]` (archive entries), `freed`, `failed[]` |
| `archive bring-back ID --json` | archive.bring-back.preview | archive.bring-back.done | `archive`, `connected`, `nowAt`, `originalExists` → the entry |
| `tidy DIR --json [--rule installers,copies] [--older 30d] [--now]` | tidy.preview | tidy.done | `root`, `rules[]` {`rule`, `about`, `count`, `size`, `items[]`, `default`}, `picked[]`, `items[]` {`path`, `size`, `why`}, `total`, `undo` → `root`, `cleaned[]`, `size`, `failed[]`, `undo` |
| `organize DIR --by kind\|date\|kind-date --json` | organize.preview | organize.done | `plan` {`root`, `by`, `moves[]` {`from`, `to`, `folder`, `size`}, `folders[]`, `skipped[]`, `foldersLeftAlone`} → `journal`, `moved`, `folders`, `failed[]` |
| `organize undo DIR --json` | organize.undo.preview | organize.undo.done | `journal`, `restored`, `removedFolders[]`, `failed[]` |
| `rename PATH... --replace A=B --case lower ... --json` | rename.preview | rename.done | `rows[]` {`from`, `to`, `problem`? (any problem stops the whole rename)}, `changing`, `blocked` → `journal`, `renamed` |
| `rename undo --json` | rename.undo.preview | rename.undo.done | as organize undo |
| `convert PATH... --to jpeg\|png\|gif --json` | convert.preview | convert.done | `to`, `pictures[]` {`from`, `to`, `format`, `width`, `height`, `note`?} → `wrote[]`, `failed[]` |
| `apps remove ID --json [--now]` | apps.remove.preview | apps.remove.done | `plan` {`app`, `command`, `checked` (the package manager's own dry run), `also[]` (what goes with it), `note`}, `undo` → `removed`, `freed`, `error`, `plan`, `undo` |
| `apps leftovers clean ID...\|--all --json` | apps.leftovers.clean.preview | | `items[]`, `undo` → `cleaned[]`, `failed[]`, `undo` |
| `stop PID\|NAME --json [--force]` | stop.preview | | `wouldStop[]`, `refused[]` {`pid`, `name`, `user`, `command`, `service`?, `useInstead`?} → `stopped[]`, `stillRunning[]`, `refused[]`, `failed[]`. A service's own program is refused with the systemctl command to use |
| `ports stop PORT --json [--force]` | ports.stop.preview | ports.stop.done | `port`, `force`, `plans[]` {`programs[]`, `containers[]`, `project`?, `leftAlone[]`} → `stopped[]`, `stillRunning[]`, `failed[]`. A service's main program: exit 3, "use instead: sudo systemctl ..." on stderr (ports.stop.service-refused in `_index.tsv`) |
| `startup off ID --json` | startup.off.preview | startup.off.done | `off`, `name`, `item`, `words` (what it runs) → `off`, `name` |
| `startup on ID --json` | startup.on.preview | startup.on.done | `on`, `name`, `change` (what was written down) → `on`, `name`. Only what ByteSweep switched off |
| `updates install --json [--security]` | updates.install.preview, updates.install.security.preview | *not run on the test VM* | `steps[]` {`manager`, `command[]`, `env[]`, `updates`}, `skipped[]`, `ran: false` → `ran: true` and what each step did. Nothing restarts by itself |
| `logins accept --json` | logins.accept.preview | logins.accept.done | `keys[]` (as logins) → `accepted[]` |
| `schedule logs --every daily\|weekly\|monthly --day sun --at 03:00 --older 7d [--docker] [--live] [--webhook URL] --json` | schedule.logs.preview | schedule.logs.done | `schedule` {`id` (the one it will get), `every`, `day`?, `at`, `older`, `docker`?, `live`?, `webhook`?, `when` (words)} → `added` (+ `next`) |
| `schedule list --json` | schedule.list | | [{... `when`, `next`? (RFC 3339, systemd only)}] |
| `schedule remove ID --json` | schedule.remove.preview | schedule.remove.done | `schedule` → `removed` (id) |
| `alerts add slack\|discord\|webhook --url URL --json`, `alerts add telegram --token T --chat C --json`, `echo PASS \| alerts add email --to A --smtp H:587 --user U --password-stdin --json` | alerts.add.preview | alerts.add.done | `target` {`id`, `kind`, `url`?, `token`/`password` shown only as `"set"`}, `about` → `added`, `about` |
| `alerts --json` | alerts.list | | `settings` {`targets[]`, `fullDays`, `certDays`, `everyMinutes`}, `on`, `open` (map of problems already told) |
| `alerts test [ID] --json` | alerts.test | | runs at once: `sent`, `of`, `failed[]` (also on stderr); exit 3 if any failed |
| `alerts on --every 30m --full-days 3 --cert-days 14 --json` | alerts.on.preview | alerts.on.done | `settings`, `timer` (the daily record is on) → `on: true`, `settings`, `timer`. Needs a place first (else exit 3) |
| `alerts off --json` | alerts.off.preview | alerts.off.done | `on`, `places` → `on: false`, `places` |
| `alerts remove ID --json` | alerts.remove.preview | alerts.remove.done | `target`, `left` → `removed`, `left`, `on` |
| `alerts run --json` | alerts.run | | what would be told now: `problems[]` {`key`, `level`, `text`}, `new[]`, `over[]`. Sends nothing; the timer sends |
| `update --check --json` | (offline: error.update-offline) | | `current`, `latest`, `update` (bool) |
| `update --json` → `--yes` | | | preview: `current`, `latest`, `update`, `dryRun` → `updated`, `path`. Needs the signed release online: the test VM gets exit 3 "server answered 404" |
| `grow --json [--disk /]` | (none: no free space after the partition on the VM, exit 3) | | `disk`, `free`, `commands[][]` → `disk`, `free`, `total`. Linux only |

## Problems explained, and server maintenance (2026-11-09)

### Problems explained

Every health finding (`health --json`, `summary --json`'s `findings`) has:

| Field | |
|---|---|
| `id` | stable kind, `area.kind`: `updates.security-waiting`, `updates.waiting`, `system.restart-needed`, `services.failed`, `services.crash-loop`, `security.ssh-root-password`, `security.no-firewall`, `backups.stale`, `backups.none`, `certificates.expired`, `drives.failing`, `clock.no-sync`, `names.not-resolving`, ... (about 60, all in `internal/health/explain.go`). Never holds anything about the machine |
| `about` | 1 or 2 plain sentences: what it means, for someone who isn't a system administrator |
| `risk` | 1 plain sentence: what can happen if it is left. `""` for `ok` findings |
| `steps[]` | what a person can do, in order (may be `[]`) |
| `action` | only when bsweep can fix it itself: {`label`, `args[]`}. Run `args` + `--json` as a preview, then `args` + `--json --yes`. Today: `["updates","install","--security"]`, `["updates","install"]`, `["services","restart","UNIT"]` (never for SSH, the network, logins or `user@`), `["reboot","--now"]` (label "Restart the server") |

SSH, firewall and system settings never get an `action`: they stay advice.

### Maintenance

Changes need root. Every change without `--yes` is a preview with `dryRun` and
`about` (a plain sentence of what would change); `--dry-run` is the same.

| Command line (add `--yes` to run) | Fixture | Fields |
|---|---|---|
| `maintain --json` | maintain.json (off), maintain.on.json | `plan` {`on`, `every` daily/weekly/monthly, `day` (weekly mon..sun, monthly 1 to 28, daily ignored), `at`, `steps[]`, `older`, `next` RFC 3339 or ""}, `window` {`on`, `days[]`, `from`, `to`, `pauseAlerts`, `inNow`}, `last` (a report, or `{}`), `restartNeeded` |
| `maintain plan --every weekly --day sun --at 03:00 --steps updates-security,logs,clean-safe,restart-services --older 7d --json` | maintain.plan.preview, maintain.plan.monthly.preview, maintain.plan.done | preview `dryRun`, `about`, `plan` → `plan`. Flags left out keep the saved values. A bad step: exit 3 (maintain.plan.bad-step in `_index.tsv`). Steps always run in this order: `backup` (see Backups below), `updates-security`, `updates-all`, `logs`, `clean-safe`, `restart-services`, `reboot-if-needed` |
| `maintain plan off --json` | maintain.plan.off.preview, maintain.plan.off.done | `dryRun`, `about`, `plan` → `plan` (`on: false`, the rest kept) |
| `maintain window --days sat,sun --from 02:00 --to 05:00 [--pause-alerts] --json` | maintain.window.preview, maintain.window.done | `dryRun`, `about`, `window` → `window`. `--pause-alerts` left out means false |
| `maintain window off --json` | maintain.window.off.preview, maintain.window.off.done | as above |
| `maintain run --json` | maintain.run.preview, maintain.run.done | preview `dryRun`, `steps[]` {`step`, `would` (sentence), `size` (bytes it would free, 0 when not known first)}, `plan`, `restartNeeded` → a report: `started`, `finished`, `by` timer/person, `steps[]` {`step`, `ok`, `did`, `freed`, `error`}, `restartNeeded`, `rebooted`. Exit 3 when a step failed (the report is still printed). Runs now, whatever the window says |
| `maintain reports --json [--limit 30]` | maintain.reports | reports, newest first, kept 90 days |
| `services --json [--failed]` | services, services.failed | `services[]` {`name`, `description`, `state` active/failed/inactive, `sub`, `since` RFC 3339 or "", `restartable`, `kept`? (why bsweep never restarts it), `log[]` (last 5 lines, failed ones only)}, `failed` (count). Failed first |
| `services restart NAME --json` | services.restart.preview, services.restart.done, services.restart.fails-again | `dryRun`, `name`, `command[]` → `name`, `ok`, `state` (after a few seconds), `error`. Started and failed again: exit 3 with the JSON. SSH, the network, logins and the system's own manager: exit 3 (services.restart.refused) |
| `reboot --json` | reboot, reboot.scheduled | `needed`, `why[]`, `packages[]`, `uptime` (seconds), `scheduled` (RFC 3339 or ""); being a preview of "restart in 2 minutes" it also has `dryRun`, `about`, `at`, `command[]` |
| `reboot --at HH:MM --json`, `reboot --now --json`, `reboot --json` (2 minutes) | reboot.at.preview, reboot.now.preview, reboot.at.done | the look + `at`, `command` → `scheduled`, `command`, `cancel` (`["reboot","cancel"]`). `--now --yes` answers `{"rebooting": true, "at", "command"}` and the connection drops |
| `reboot cancel --json` | reboot.cancel.preview, reboot.cancel.done | `dryRun`, `about`, `scheduled`, `command` → `cancelled` (false when none was set), `scheduled: ""` |
| `backups --json` | backups | `found[]` {`tool`, `where`, `last` RFC 3339 or "", `ageHours`, `ok`, `note`}, `stale` (no good backup within 26 hours, or none), `newest` |
| `alerts add backups --hours 26 --json` | alerts.add.backups.preview, alerts.add.backups.done, alerts.run.backups | `dryRun`, `watch` {`kind`, `hours`}, `about` → `added`, `about`. `alerts remove backups` stops it. `alerts --json`'s `settings` gains `backupHours` (0 = not watched) |

The plan runs from the timer `bytesweep-maintain`. With a window on, the plan, log schedules and
cleaning by itself wait for it (what came due runs when it opens, from `bytesweep-window`); with
`pauseAlerts` nothing is sent inside it and what is still true is sent after. `reboot-if-needed`
restarts in 2 minutes and only inside the window when there is one.

## Disk full in N days: forecast (2026-11-09)

Only reads files the monitor (`monitor on`, a sample every 5 minutes, 30 days) and the daily
record (`timer on`, which folders grew) wrote; no root needed to read (sudo
works as everywhere). The pace is a least-squares line through the last 14 days (hourly points
from the samples, or the daily record when it covers more days). A sudden drop (a clean) is set
aside when it happens at most twice in the window; drops that keep coming, such as a nightly
rotation, are the disk's own pattern and stay in. A disk needs 2 days of history.

| Command line | Fixture | Fields |
|---|---|---|
| `forecast --json [--disk PATH] [--days 30]` | forecast (/ fills in about 14 days), forecast.critical (a test disk, 2 days, exit 2), forecast.not-enough (an hour of samples), forecast.disk (`--disk /var/log` gives the disk that holds it, `/`), forecast.days-7 | `now` RFC 3339; `days` (the `--days` asked: how soon counts as soon); `recording` (monitor on); `dailyRecord` (timer on); `enoughHistory` (any disk has 2 days); `switchOn[]` (bsweep words that would record what is missing: `["monitor","on"]`, `["timer","on"]`; `[]` when both are on; run them as any change: preview, then `--yes`); `say` (one plain sentence for the whole server: the soonest disk's `say`, or how to get a forecast); `disks[]` below; `soonest` {`path`, `daysLeft`, `fullOn`, `confidence`} or `{}` when no disk fills within a year |
| `summary --json` | summary.forecast | gains `forecast`: the same `soonest`, `{}` when none. Read from the files only, so summary stays quick |
| `health --json` | health.filling-soon | finding `disk.filling-soon` (area `Disks`): `warn` under 14 days, `bad` under 3 (a `low`-confidence one stays `warn`). Title like "/ will be full in about 13 days (around 22 Nov) at this rate; /var/lib/docker grows 1.1 GB a day". `seeWhy` `bsweep forecast --disk PATH`. `action` by what grows most: a log or journal folder `["logs","clear"]`, Docker/Podman/containers `["clean","--group","containers","--safe"]`, else `["clean","--safe"]`: run with `--json` as the preview first, as every action |
| `alerts add forecast --days 7 --json` (`--days` 1 to 90) | alerts.add.forecast.preview, alerts.add.forecast.done | as `backups`: `dryRun`, `watch` {`kind` "forecast", `days`}, `about` → `added`, `about`. `alerts --json`'s `settings` gains `forecastDays` (0 = not watched). While it is set, the older "full within `fullDays`" alert is not checked (the forecast covers it) |
| `alerts remove forecast --json` | alerts.remove.forecast.preview, alerts.remove.forecast.done | `dryRun`, `watch` → `removed` "forecast", `left`, `on` |
| `alerts run --json` | alerts.run.forecast, alerts.run.forecast.worse | problems gain key `forecast:PATH`, `level` warning (critical under 3 days), `text` = the disk's `say` + "(high confidence)", and `rank`. Told once; told again only when `rank` rises (each time the days left halve from `--days`: 7, 3.5, 1.75, under a day); better and then back is not told again |

Each of `disks[]`:

| Field | |
|---|---|
| `path`, `total`, `free` | the disk now (`free` is what is available, as `summary`) |
| `enoughHistory` | false until the disk has 2 days of samples or daily records |
| `historyDays` | days the fit covers (0.1 steps) |
| `source` | `monitor` (5-minute samples), `daily` (the daily record), `""` with no history at all |
| `perDay` | bytes a day; below 0 when it is emptying; 0 without enough history |
| `trend` | `growing`, `flat`, `shrinking`, or `unknown` (not enough history). Growing and shrinking only when the line stands well clear of the noise |
| `fullOn` | `YYYY-MM-DD`, or `""` when not growing, more than a year away, or not enough history. A full disk that still grows has today and `daysLeft` 0 |
| `daysLeft` | days, one decimal; `-1` when `fullOn` is `""` |
| `soon` | full within `--days` |
| `confidence` | `low`, `medium`, `high` (7+ days and a steady line is high; under 3 days is low); `""` without enough history |
| `setAside` | how many one-off drops (cleans) were left out of the line |
| `growing[]` | up to 3 folders on this disk that grew most in the daily record's last week: {`path`, `perDay` bytes a day}; `[]` without the daily record |
| `say` | one plain sentence: "/ will be full around 22 Nov at this rate, in about 14 days; /var/lib/docker grew 1.1 GB a day this week." / "/boot isn't filling up: about the same over the last 14 days." / "/ has an hour of history; a forecast needs 2 days." |

Exit: 0 nothing fills within `--days`, 1 a disk does, 2 a disk fills within 3 days (the JSON is printed in every case).
How the fixtures were made: `TestSeedRealHistory` in `internal/forecast` (BSWEEP_SEED_DIR,
BSWEEP_SEED_DAYS, BSWEEP_SEED_DISK) writes 30 days of samples and a daily record that end at what
the disks use now; the test binary ran in its own mount namespace with a copy of
`/var/lib/bytesweep` and `/etc/bytesweep`, so the VM's real files were not touched.
## Snapshots (2026-11-09)

Space hidden in system snapshots, each with its date, and removal **only through the tool that
made it** (never by deleting files). A snapshot may be someone's only way back: **never tick one
for the person**, never offer "Select all" without saying the newest of each is kept, and say a
removed snapshot can't be put back (there is no Undo for it).

| Command line | Fixture | Notes |
|---|---|---|
| `snapshots --json [--tool T]` | snapshots.json, snapshots.nosudo.json, snapshots.tool.json, snapshots.after.json, snapshots.mac.json, snapshots.windows-sample.json | the list (below); exit 0. Without sudo most Linux tools can't be read: the fields are the same, fewer snapshots, and `notes` says which (also on stderr) |
| `snapshots remove ID... [--keep-newest N] --json` / `--yes` | snapshots.remove.preview.json, snapshots.remove.done.json, snapshots.remove.newest.done.json | the IDs from the list; quote each for the shell (IDs have `:` `/` `@` `{}`) |
| `snapshots thin [--tool T] [--keep-newest N] --json` / `--yes` | snapshots.thin.preview.json, snapshots.thin.tool.preview.json, snapshots.thin.done.json | every removable snapshot (of one tool) but the newest N of each group |
| `snapshots resize --max 5%\|10GB\|UNBOUNDED [--for C:] --json` / `--yes` | snapshots.resize.notwindows (exit 3 off Windows) | Windows only: runs `vssadmin resize shadowstorage /for=C: /on=C: /maxsize=…`. Preview `{dryRun, for, max, command[], now?}` (`now` is the drive's `shadowStorage` row); done `{for, max, command[]}`. `--max` below 320MB, 0% or over 100% is refused (exit 3) |
| `clean --list --group snapshots --json` | clean.list.snapshots.json | one row a tool, `level: manual`, `id` `<tool>-snapshots`, `command` `bsweep snapshots --tool <tool>`: the same counts and sizes as `totals`. Clean never removes a snapshot |

`remove`, `thin` and `resize` need root even to preview (exit 5 without: most tools list nothing
to a normal user); `--keep-newest` is 1 by default: the
newest snapshot of each group is kept and comes back in `kept` with its reason. `--keep-newest 0`
is refused (exit 3) unless `--i-understand` is added too: show the person a second, separate
question before sending it.

**The list**, `snapshots --json`:

| Field | |
|---|---|
| `system` | `linux`, `darwin`, `windows`, ... |
| `tools` | the snapshot tools found here, with snapshots or not: `timemachine-local`, `apfs`, `restore-point`, `shadow-copy`, `timeshift`, `snapper`, `zfs`, `btrfs`, `lvm` |
| `snapshots[]` | oldest first within each group, the groups in the order of `tools` above |
| `totals[]` | {`tool`, `name` (for people), `count`, `size`, `sizeKnown`} for each tool with snapshots. Shadow copies' `size` is the storage they use (Windows sizes them together) |
| `shadowStorage[]` | Windows: {`for` (C:), `on`, `used`, `allocated`, `max` (-1 no limit), `maxPercent` (0 when no limit)}; `[]` elsewhere |
| `notes[]` | what couldn't be read, in plain words (also on stderr) |

Each snapshot:

| Field | |
|---|---|
| `id` | what `remove` takes. Time Machine `2026-11-09-101530`, APFS `apfs:UUID`, restore point `restore-point:42`, shadow copy `{GUID}`, Timeshift `2026-11-08_03-00-01`, Snapper `snapper:CONFIG:N`, ZFS `pool/fs@snap`, Btrfs `btrfs:/mount/path`, LVM `lvm:vg/lv` |
| `tool` | one of the tools above |
| `when` | when it was made; `0001-01-01T00:00:00Z` when the tool can't say (APFS update snapshots) |
| `size`, `sizeKnown` | bytes this snapshot alone holds; `-1` and `false` when the tool can't tell (Time Machine, Timeshift, restore points, shadow copies, Snapper and Btrfs without quotas). Show "size unknown", never 0 |
| `description` | the tool's own words: Snapper's description, Timeshift's kind (daily, on demand...) and comment, the restore point's description and what made it |
| `where` | its group: the volume, Snapper config, Timeshift device, ZFS dataset, Btrfs mount or LVM origin. `newest` and `--keep-newest` count per tool and `where` |
| `disk` | the mount point whose space it holds, when known ("" for LVM and an unmounted Timeshift device) |
| `newest` | the newest of its group: removed only with `--keep-newest 0 --i-understand` |
| `canRemove` | `false` for APFS (macOS's own, never), Btrfs and LVM (explained only), and the Snapper snapshot the system started from. Show those without a tick box |
| `removeCommand[]` | what `remove` would run (`canRemove` true), or for Btrfs and LVM the command for the person to copy and run themselves. `[]` for APFS |
| `note` | one or two sentences for people: what made it, what removing it means |

**Preview** (`remove`/`thin` without `--yes`): `{dryRun: true, action: "remove"|"thin",
keepNewest, remove[] (snapshots, as above), kept[] (snapshots plus why), commands[] (each removal as a
command line, in order), freed, freedKnown}`. `freed` adds up the known sizes; `freedKnown` false
means some sizes are unknown, so say "at least" (or "unknown" when `freed` is 0). A snapshot that
can't be removed, or is among the newest kept, is in `kept`, never in `remove`.

**Done** (`--yes`): `{action, keepNewest, removed[], kept[], failed[] ({id, error}), freed, freedKnown}`.
Exit 0; exit 3 with the same JSON when any `failed` (the rest were still removed). Each removal is
written to the history (`history --json`, action `snapshots remove`).

An ID nobody has: exit 3, "no snapshot has the ID ...". Times on Windows are the PC's own offset.
The Windows fixture is the parser run over sample captures, not a live PC (none in the lab).
## Backups ByteSweep sets up: `bsweep backup` (2026-11-09, branch `cli-backup`)

`backups` (above) finds every backup on a machine, whoever made it. `backup` makes and runs
them, with **restic** underneath (encrypted, only changes copied; ByteSweep has no backup format
of its own). The look is free and needs no root. `list`, `check` and `remove` need root;
`add`, `run`, `restore` and `install-restic` with `--yes` need root (exit 5 as everywhere). Every change without `--yes` is a preview with `dryRun`; `--dry-run` is the same.
Ids are `b1`, `b2`, ... (a bad or unknown id: exit 3, "no backup b9").

**Plan** (in `plans[]`, `plan`, `added`):

| Field | |
|---|---|
| `id` | `b1` ... |
| `folders[]` | absolute folders, cleaned; a folder inside another is dropped |
| `target` | {`kind` disk/sftp/s3/b2/rest, `where`}: a folder, or the restic words (`sftp:user@host:/path`, `s3:host/bucket/dir`, `b2:bucket:dir`, `rest:https://host/`). Never a password or key: a user and password inside a rest address are taken out and kept as keys |
| `keep` | {`daily`, `weekly`, `monthly`}: copies kept after each run (default 7, 4, 6) |
| `schedule` | {`every` daily/weekly/monthly or "", `day` (weekly mon..sun, monthly 1-28, else ""), `at` HH:MM or "", `withMaintenance`, `when` (words: "every day at 02:00", "every Sat at 01:30", "with the maintenance plan")} |
| `created` | RFC 3339 |
| `keys[]` | names of the stored keys (`AWS_ACCESS_KEY_ID` ...), never values |
| `sameDisk` | set up with `--same-disk-ok`: this copy is lost with the disk (show it amber) |
| `last` | the last run's report (below); `time` `0001-01-01T00:00:00Z` = never ran |
| `lastOK` | RFC 3339 of the last good run, zero when none |
| `next` | RFC 3339 of the next run by itself, "" when none (a `withMaintenance` plan while the maintenance plan is off or has no `backup` step) |
| `timer` | its own timer is installed (`bytesweep-backup-ID`; false for `withMaintenance`) |

**Run report** (`run ID --yes`, each of `runs[]`, `last`): `id`, `time`, `ok`, `added` (bytes this
run added to the repository), `total` (bytes in the folders), `files` (looked at), `changed` (new or
changed), `duration` (seconds), `snapshot` (restic's full id), `snapshots` (copies kept now),
`forgotten` (old copies thinned by the keep rule this run), `warnings[]` (files that couldn't be
read; the copy is still made and `ok` stays true), `error` ("" when ok), `by` person/timer/maintenance.

**Snapshot** (`snapshots[]`, `snapshot`): `id` (short, what `restore` takes), `full`, `time`, `size`
(bytes in the folders then), `files`, `paths[]`. Newest first.

| Command line (add `--yes` to run) | Fixture | Fields |
|---|---|---|
| `backup --json` | backup (3 plans), backup.never-run, backup.empty, backup.no-restic | `plans[]`, `resticInstalled`, `resticVersion` ("" when missing), `install` {`manager` apt/dnf/yum/apk/pacman/zypper/pkg/brew/winget or "", `commands[][]` (run in order; EL adds `epel-release` first), `root` (false for brew: run without sudo), `note`} |
| `backup install-restic --json` | backup.install-restic.preview, .done, .installed | preview: `dryRun`, `installed`, `version`, `install` → `installed`, `version`, `install`, `ran[][]`. Already installed: answers at once with `ran: []`. The package manager's output goes to stderr. Never curl \| sh |
| `backup add --folders A,B --to TARGET [--keep 7,4,6] [--every daily\|weekly\|monthly --day D --at HH:MM \| --with-maintenance] [--key-file F \| --key-stdin] [--same-disk-ok] --json` | backup.add.preview, backup.add.s3.preview, backup.add.sftp-maintenance.preview, backup.add.no-restic.preview → backup.add.done | preview: `dryRun`, `plan` (with the id it will get), `about` (sentence), `resticInstalled`, `maintenance` {`planOn`, `stepAdded` (the maintenance plan gains the `backup` step)} → `added` (plan), **`password`**, `keepPassword` (the sentence to show with it), `passwordFile`, `about` |
| | backup.add.same-disk.refused, backup.add.sftp.refused, backup.add.not-empty.refused | exit 3, stdout empty, the reason on stderr: a disk target on the same physical disk as a folder (partitions, LVM and loop files are followed to their disk), an SFTP target on this machine, or a folder target that isn't empty or already holds a restic repository |
| `backup run [ID] --json` | backup.run.preview, backup.run.all.preview | `dryRun`, `plan` (or `plans[]` without ID), `would` (sentence), `resticInstalled` |
| `backup run ID --json --yes` | backup.run.done, backup.run.first | the run report. Exit 3 when `ok` is false (the report is still printed) |
| `backup run --json --yes` | backup.run.all.done | `runs[]` (reports), `ok` (all worked) |
| `backup list ID --json` | backup.list, backup.list.after | `id`, `snapshots[]` |
| `backup check ID --json` | backup.check | runs at once (it only reads): `id`, `ok`, `said[]` (restic's last lines), `error`. Exit 3 when not ok |
| `backup restore ID SNAPSHOT --to DIR [--path P] --json` | backup.restore.preview, backup.restore.path.preview → backup.restore.done, backup.restore.path.done | SNAPSHOT is a short id or `latest`. `id`, `snapshot`, `path`, `to`, `inPlace`, `files`, `bytes` (what it writes), + `dryRun`, `about` → + `ok`, `duration`, `error`. Files keep their path under DIR (`/srv/site` lands in `DIR/srv/site`). DIR must be empty or new, not `/` and not a folder the plan copies |
| `backup restore ID SNAPSHOT [--path P] --in-place --i-understand --json` | backup.restore.in-place.preview | `to: "/"`, `inPlace: true`: writes over today's files. Without `--i-understand`: exit 3 (backup.restore.in-place.refused); a DIR that isn't empty: exit 3 (backup.restore.not-empty.refused) |
| `backup remove ID [--forget-data] --json` | backup.remove.preview, backup.remove.forget-data.preview → backup.remove.done, backup.remove.forget-data.done, backup.remove.b1 | `dryRun`, `plan`, `forgetData`, `about` → `removed` (id), `forgetData`, `dataRemoved`, `forgotten` (copies removed from a remote repository), `passwordKept` (without `--forget-data` the copies stay and the password that reads them is moved to this root-only file; "" otherwise) |
| `backups --json` | backups.with-plans | ByteSweep's plans show as tool `ByteSweep backup ID`, from their own run records |

The password is shown **once**, in the `add --yes` answer: show it big with `keepPassword`, offer
copy, and never store it on the desktop. It stays root-only (0600, in a 0700 folder) at
`passwordFile` for the timer. S3/B2 keys: over SSH sudo drops the environment, so send them on
stdin: `printf 'AWS_ACCESS_KEY_ID=...\nAWS_SECRET_ACCESS_KEY=...\n' | sudo -n bsweep backup add ...
--key-stdin --json --yes` (B2: `B2_ACCOUNT_ID`, `B2_ACCOUNT_KEY`; rest: `RESTIC_REST_USERNAME`,
`RESTIC_REST_PASSWORD`). They are kept 0600 and never printed. An SFTP target uses root's own SSH
key on the server (the desktop should say so: "root on this server must be able to log in to
HOST with a key").

Schedules: a plan's own timer runs at its time and does **not** wait for the maintenance window (a
backup changes nothing on the server). `--with-maintenance` runs it in the maintenance plan's new
first step `backup`, which waits for the window like the rest of the plan. The step runs every
plan; its line in `maintain run --json`'s preview is `would: "Back up b1 (...), then thin old
copies."`, and its report step is `{"step": "backup", "did": "Backed up b1 (2.9 MB added), b2 (0 B
added)."}`. `maintain plan --steps` now also takes `backup`; steps run in the order `backup`,
`updates-security`, `updates-all`, `logs`, `clean-safe`, `restart-services`, `reboot-if-needed`.

Health: `backups.failed`, `backups.stale`, `backups.late` and `backups.never-finished` for a
ByteSweep plan carry `action` {`label`: "Run backup b1 now", `args`: `["backup","run","b1"]`}.
`backups.none` carries `action` {`label`: "Set up a backup to /mnt/disk2/bytesweep-HOST", `args`:
`["backup","add","--folders","/etc,/srv,/home","--to","/mnt/disk2/bytesweep-HOST"]`} only when a
disk with 1 GB free is mounted under /mnt, /media, /backup*, /data* or /Volumes and isn't the
system's disk (none on the test VM: its /mnt/backup is a file on the system disk). Its `steps`
now name `bsweep backup add`.
## Fleet: many servers from one place (2026-11-09)

`fleet` runs on the machine you watch **from** (a laptop or one server), about the servers saved
in its `bsweep.yml` (`host add`). It is not called over SSH like the commands above: a desktop
app that already drives each server itself doesn't need it, but can run it locally, or on a
jump server over SSH, for one answer about many. No root is needed on the watching machine; each server's own `sudo -n` decides what that server does. Every
remote call is `sudo -n bsweep <fixed words> --json` (the status looks fall back to no sudo).
Fixtures were captured in the VM against itself under two names, `web1` and `web2`, plus `dead`
(port 1, refused).

| Command line | Fixture | Fields |
|---|---|---|
| `host tag NAME prod,db`, `host untag NAME [db]` | (text) | tags are saved in `bsweep.yml` as `tags: [db, prod]` (letters, numbers, `-`, `_`, up to 32). `untag` with no tag takes them all off. A bsweep older than this refuses a `bsweep.yml` with `tags` (unknown key) |
| `fleet status [--hosts a,b \| --tag T] [--sort name\|disk\|updates\|problems] [--parallel 8] [--timeout 60s] --json` | fleet.status, fleet.status.tag | a list, one per server, sorted (default `disk`: fullest first; those that didn't answer last): `name`, `address` (`user@host`, `:port` when not 22), `tags[]`, `reachable` (SSH got in), `error` ("" when fine; else why: ssh's own words, a time limit, no bsweep there, summary failed), `bsweepVersion`, `root` (`sudo -n` worked), `fullest` {`path`, `pct`, `inodePct`, `free`, `total`} (the disk with the highest of pct and inodePct), `disks[]` (same shape), `safe` (bytes), `forecast` {`known`, `daysLeft`, `path`} (the soonest disk to fill, when that server's bsweep reports a forecast; `known: false` until then), `updates` {`total`, `security`, `restartNeeded`, `checked` RFC 3339 or ""} (the server's last check, never a fresh one), `problems[]` (titles of bad findings), `warnings[]` (titles of warn findings), `failedServices[]` (unit names, as `services restart` takes), `maintenance` {`known`, `planOn`, `every`, `next`, `lastRun` {`ran`, `ok` (every step ok), `time`}}, `backups` {`known`, `stale`, `newest`, `found` (count)}, `cpu`, `memPct`, `missing[]` (commands that server's bsweep lacks: `maintain`, `backups`, `forecast`; their fields stay empty with `known: false`), `checked` (when asked), `seconds` (how long it took). 8 servers at a time, each with its own time limit: one that can't be reached doesn't hold up the rest. Exit 2 when any server can't be reached, has an error or a problem, or a disk at 95%; 1 for warnings (85%, warnings, security updates, stale backups, a failed last maintenance run); else 0 |
| `fleet run ACTION [NAME] (--hosts a,b \| --tag T \| --all) --json` | fleet.run.clean-safe.preview, fleet.run.updates-security.preview, fleet.run.maintain-run.preview, fleet.run.services-restart.preview | the preview: every server's own preview, gathered (all at once, 8 at a time, nothing changes). `dryRun: true`, `action`, `service` (services-restart only), `about` (sentence), `command[]` (the words each server ran), `parallel`, `hosts[]` (below), `ok`, `failed`, `skipped`, `stopped`, `freed` (bytes the previews say would come back), `started`, `finished`. Exit 1 when a server failed its preview (the rest still in the JSON) |
| the same with `--yes` | fleet.run.logs-clear.done, fleet.run.logs-clear.stopped, fleet.run.logs-clear.keep-going | the run: no `dryRun`. One server at a time unless `--parallel N`; after the first failure the servers not yet started are `skipped` (`stopped: true`) unless `--keep-going`. Exit 3 when any server failed or was skipped, else 0. Written to `fleet history` |
| `hosts[]` in both | | `name`, `ok`, `skipped`, `did` (one plain sentence from the server's answer: "Would clean 2 safe items: 429.0 MB.", "Cleared old logs: 66.1 MB back.", "Would install 3 updates with apt.", "Would run updates-security, logs, clean-safe, restart-services.", "Restarted nginx.service: active."), `freed` (bytes; in a preview, what would come back), `error` (""; or why: can't reach it, needs sudo without a password, older bsweep, the server's own stderr line), `exit` (that server's bsweep exit code; -1 when it never ran), `restarts` (maintain-run: that server's plan has `reboot-if-needed`, or it is restarting), `output` (that server's own JSON answer, exactly as its command gives it, `{}` when none), `seconds` |
| `fleet history [--limit 30] --json` | fleet.history | newest first, kept 90 days, on the watching machine (`fleet-history.jsonl` beside `bsweep.yml`): {`time`, `kind` status/run, `action`, `service`, `ok`, `failed`, `skipped`, `freed`, `hosts[]` {`name`, `ok`, `did`, `freed`, `error`, `fullestPct`, `updates`, `security`, `problems`}}. Previews are not written; every `fleet status` from the command line and every `--yes` run is |

ACTION is one of: `updates-security` (`updates install --security`), `updates-all` (`updates
install`), `clean-safe` (`clean --safe`), `logs-clear` (`logs clear --older 7d`), `maintain-run`
(`maintain run`: that server's own plan, which may include `reboot-if-needed`; `restarts` says
so in the preview), `services-restart NAME` (`services restart NAME`; NAME is letters, numbers
and `@._:-`). Anything else exits 3 (`fleet.run.bad-action`); no servers named exits 3
(`fleet.run.no-hosts`). A server with no bsweep is reported, not given a copy (the old
`fleet HOST...` still does that, for looks). Windows servers aren't reached (the scripts are sh).
Time limits: `--timeout`, default 60s for status, 3 minutes for a preview, 10 minutes a server for
a run, 30 for updates and maintain-run.
## Use with an AI assistant: `bsweep mcp config` (2026-11-09)

`bsweep mcp` is an MCP server for Claude Desktop, Claude Code, Cursor and VS Code (docs/mcp.md).
The desktop apps don't speak MCP themselves; they can offer a **Use with an AI assistant** button
that shows how to add it. Free, no sudo, changes nothing.

| Command line | Fixture | Fields |
|---|---|---|
| `mcp config CLIENT --json` (CLIENT: `claude-desktop`, `claude-code`, `cursor`, `vscode`) | mcp.config.claude-desktop, mcp.config.vscode | one setup: `client`, `name` (`"bsweep"`), `command` (absolute path of bsweep, or `"sudo"`), `args[]`, `allowChanges`, `needsSudo` (changes go through `sudo -n`, so the user needs NOPASSWD for bsweep), `file` (settings file to merge `json` into; `""` for Claude Code), `json` (`{}` when there is no file), `shell` (a command to type: Claude Code's `claude mcp add ...`, VS Code's `code --add-mcp ...`; `""` otherwise), `note` (one plain sentence to show) |
| `mcp config CLIENT --allow-changes --json` | mcp.config.claude-code.allow | the same, set up so the assistant may apply a plan after the person's yes (`args` end with `--allow-changes`; on Linux/macOS without root `command` is `sudo` and `args` start `-n`) |
| `mcp config --json` | mcp.config | `{"clients": [...]}`: one setup per assistant, in the order above |
| `mcp config chatgpt --json` | mcp.config.bad-client (`_index.tsv`) | exit 3, the known names on stderr |

Run it **where the assistant runs**: `file` and `command` are that machine's. For the person's
own Mac or PC, run the local bsweep. For a server the desktop manages, Claude Desktop on the
person's computer reaches it over SSH: take `command` + `args` from the server's
`mcp config claude-desktop --json` (run without sudo) and write, under `mcpServers`, a name for
the server with `{"command": "ssh", "args": ["-T", "-o", "BatchMode=yes", "USER@HOST", "<command and args joined, quoted for the remote shell>"]}`.
The MCP tools also cover `forecast`, `snapshots`, `backup` and `fleet` (looks, plus
plans for snapshots remove/thin, backup run/restore and fleet run; docs/mcp.md lists what is
never offered there). Nothing in this section's JSON changed for them.
Never write the person's settings file without showing it first; merge into `mcpServers`, keep
the other servers. Wording: "Let Claude look at this server and plan cleaning. It changes
nothing unless you switch on changes, and then only after your yes."

## Rescue USB (2026-11-09)

A desktop screen "Make a Rescue USB" needs two commands. Both are free.
Fixtures: `desktop-json/rescue-usb*.json`, captured in the VM against a locally signed test
release (so `url` shows `http://127.0.0.1:8899/...`; the real one is
`https://bytesweep.app/downloads/bsweep-rescue-ARCH.iso`).

**Download** `bsweep rescue-usb --arch x86_64|aarch64 [--out FILE] --json` is the preview:
{`dryRun`: true, `file`, `arch`, `version`, `sha256`, `url`}. Nothing is downloaded. Add `--yes`
to download: {`file`, `arch`, `version`, `size`, `sha256`, `verified`: true, `url`}. A file that
doesn't match the signed list is deleted and the command exits 3 with nothing on stdout
(`rescue-usb.error.tampered`). The default arch is this computer's; a PC needs `x86_64`.

**Write** `sudo -n bsweep rescue-usb write --image FILE --device DEVICE --json` is the preview:
{`dryRun`: true, `image`, `imageSize`, `device`: {`device`, `model`, `size`, `kind`
(`usb`|`internal`|`loop`|`file`), `removable`, `system`, `mounted[]`}, `verdict`: {`refused`,
`needsConfirm`, `reason`}}. Show `model` and `size` before anything else.
- `refused` not "" (the disk the computer runs from, or too small): exit 3, the JSON still
  printed (`rescue-usb.write.preview.refused`). Offer no button.
- `needsConfirm` true (built in, virtual, or a part mounted: `reason` says which, in plain
  words): make the person type the device name, then run with `--confirm DEVICE --yes`.
  Without it `--yes` exits 3 (`rescue-usb.write.error.needs-confirm`).
- Otherwise `--yes` writes. Result: {`device`, `image`, `written`, `verified`: true,
  `seconds`}. Exit 3 with the reason on stderr if it couldn't write or the read-back differed.
- DEVICE is `/dev/sdX` on Linux (lsblk), `/dev/diskN` on macOS (diskutil list, written
  through `/dev/rdiskN`, ejected after), `\\.\PhysicalDriveN` on Windows (Get-Disk; volumes
  locked and dismounted while writing). Root/Administrator: exit 5 without it.
  macOS and Windows are compile-tested only.

On the USB itself (not for desktop screens, fixtures from QEMU):
`rescue-boot --list --json` {`parts[]`: {`device`, `disk`, `model`, `size`, `fsType`, `label`,
`system` (linux|windows|macos|efi|swap|locked|lvm|data|unknown), `name`, `used`, `free`, `pct`,
`cleanable`, `hibernated`, `note`}, `target`, `onUSB`}. `rescue --root /mnt/target --json`
answers as the usual preview.
`why --root`, `clean --root` answer as without it, for that disk only.

## Errors captured

| Fixture row in `_index.tsv` | Exit | stderr |
|---|---|---|
| error.needs-root (`bsweep schedule remove s1 --json --yes` without sudo) | 5 | run with sudo |
| error.needs-root.alerts (`bsweep alerts --json` without sudo) | 5 | run with sudo |
| error.bad-usage (`undo restore nosuchid --json --yes`) | 3 | no Undo entry nosuchid |
| error.update-offline (`update --check --json`) | 3 | bsweep-SHA256SUMS.txt: server answered 404 |

The stderr text is for people and may change; branch on the exit code only.

## What changed on 2026-11-09 (contract stays 1: only fields and commands were added)

- Trial (branch `cli-trial`): a 3-day trial per machine, removed again in 1.0.1 (Free section).

- New: `rescue-usb` (download, `write`), `rescue-boot`, and `--root` on rescue, clean, why, top (Rescue USB section). `rescue --json` previews gained `free`. ntfs-3g mounts (fuseblk) now count as disks.
- `health` findings gained `id`, `about`, `risk`, `steps`, `action`.
- `summary` gained `updates` and `findings`.
- `stats --history --json` is an object, not a list (the one shape change), with `--since` and
  `--points`; samples gained `disks`; history is kept 30 days, was 7.
- `monitor on/off --json` preview, then `--yes`.
- New: `maintain` (plan, window, run, reports), `services` (and `restart`), `reboot` (and
  `cancel`), `backups`, `alerts add/remove backups`. `version --json`'s `json` lists them.
- New (forecast branch): `forecast --json`; `summary`'s `forecast`; health `disk.filling-soon`;
  `alerts add/remove forecast` and `forecastDays`; alert problems may carry `rank`.
- New (branch `cli-backup`): `backup` (add, run, list, restore, check, remove, install-restic);
  the maintenance step `backup`; `action` on ByteSweep backups' health findings and on
  `backups.none`.
- New: `mcp config [CLIENT] [--allow-changes] --json` for a "Use with an AI assistant" button
  (section above); `version --json`'s `json` lists `mcp`.
- Fixtures were captured with a 30-hour-old dump in `/srv/backups`, the monitor on, and alerts watching backups.

## What changed: snapshots (2026-11-09, contract stays 1)

- New: `snapshots` (list), `snapshots remove`, `snapshots thin`, `snapshots resize` (Windows);
  fixtures `snapshots.*` and `clean.list.snapshots`. `clean --group snapshots` rows are now one per
  tool (`<tool>-snapshots`, was `zfs-snapshots`/`lvm-snapshots`/`btrfs-snapshots` on Linux only)
  and appear on macOS and Windows too. `health` can give `system.snapshots-hold-space` (area
  `Disk`, warn) with the action `snapshots thin --keep-newest 1`.
- Snapshot fixtures were captured on loop files only.
- Fleet (stage 7): `fleet status`, `fleet run`, `fleet history`, `host tag`/`untag` (see "Fleet").
  Runs on the watching machine; servers need nothing new (it reads `summary`, `maintain`,
  `backups`, and `forecast` when there is one). `bsweep.yml` hosts gained `tags`.

## What changed for this contract (from bsweep before 2026-11-06)

Previews under `--json` where these used to act at once: `startup off/on`, `ports stop`,
`undo restore/free ID`, `logins accept`, `schedule logs/sync/remove`, `alerts add/remove/on/off`,
`update`. New `--json`: `version`, `advanced`, `config check`, `alerts add/remove/test/on/off`, `schedule logs/remove`,
`logins accept`. `dryRun` added to `stop`, `logs clear`, `updates install` previews.
`schedule list` items gained `when` and `next`. `history` is another name for `log`. No `null`
lists anywhere. Fixes found on the way: MariaDB 11.8's `/var/lib/mariadb`; `ports stop` on a
service's own program; `dupes --keep` with overlapping folder and file copies; ShareSafe's SSH
fix on a socket-activated sshd.

## Not tested on the VM

Backups (2026-11-09): S3, B2 and REST targets against real services (previews only; keys from
`--key-file` and `--key-stdin` were checked, nothing was sent), restic on macOS, Windows and other
distributions (`install-restic` ran with apt only; the dnf/EPEL, apk, pacman, zypper, brew and
winget commands are unit-tested), launchd/Task Scheduler/cron timers for backups (systemd's fired
for real), the `backups.none` action (the VM has no second disk), a backup big enough for restic's
lock to meet the maintenance step.
Fleet (2026-11-09): only the VM watching itself under two names plus an unreachable one (and a
blackholed address, which took its 10 s SSH connect limit while the others answered). Not run
with `--yes`: `updates-security`, `updates-all`, `maintain-run`, `services-restart`, `clean-safe`
(the VM is shared; their previews were captured). Not tried: real separate servers, a server with
no bsweep, an older bsweep without `maintain`/`backups` (unit-tested), macOS or BSD servers,
a `forecast` from a real server (no bsweep has one yet: `missing` lists `forecast` everywhere).

Maintenance (2026-11-09): `updates-all` and `reboot-if-needed` were not run for real (the VM
needs a restart, which would cut everyone off); `reboot --now --yes`; services and reboot on macOS,
Windows and OpenRC (they build, and the parsers have tests).


`updates install --yes` (183 packages), `update --yes` (no signed release online), `grow`
(no free space to grow into), `alerts` to real Slack/Discord/Telegram/email
(webhook to the local fake only), Docker/Podman items (none installed), `--now` runs (previews
only), and other distributions (tested separately).
