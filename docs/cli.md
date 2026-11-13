# Command line

Run `bsweep help COMMAND` or `bsweep COMMAND --help` for examples. Flags work before or after names.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Fine, or the job was done |
| 1 | Warning, or it ran but fell short of its target |
| 2 | Critical |
| 3 | Error: bad usage, or something failed |
| 4 | Not used since 1.0.1 (it was "needs a licence"; ByteSweep CLI is free now) |
| 5 | Needs root (or Run as administrator on Windows) |

## Free

Since 1.0.1 every command runs on every machine with no licence, no key and no trial. A
change still needs root (or Run as administrator) where it touches the system, as before.
`licence`, `activate` and `deactivate` are kept only so old scripts get an answer: they say
it is free, change nothing and exit 0 (`--json`: `{"licensed": true, "free": true, "key": "not needed"}`).
`version --json` and `summary --json` keep `"licensed": true` too, for the desktop apps of 3.3.

## JSON

`--json` is on: copy-to, copy-from, sync, logs, schedule list, report, why, top, find, dupes, ports, stop, updates, startup, sleep, permissions, sharesafe, databases, sites, jobs, logins, before, after, alerts (list and run), apps, rm, compress, archive, clean, rescue, ci, undo, check, live, stats, grown, forecast, health, drives, grow,
maintain, services, reboot, backups,
fleet, log (history), diff, update, config, version, advanced.
Only timer, auto and motd print plain text. With `--json`, nothing changes without `--yes`, because
there is no one to ask: the answer is a preview with `"dryRun": true`. Size fields are bytes, lists
are `[]` and maps `{}`, never `null`. Errors go to stderr with an exit code, not as JSON.
`bsweep version --json` lists the commands that answer in JSON. How the desktop apps use all of
this over SSH, with real outputs: [desktop-contract.md](desktop-contract.md).

`top` lists single files of 4 MB or more, which is what the scan keeps; `find` sees every file.

## Live

`bsweep live` opens the app on its Live screen (key `0`): CPU with its history and every core,
memory and swap, load, network and disk reads and writes per second, each disk's fullness, and
every program with its process ID, CPU and memory. Advanced (below) adds each core's history,
the load over 1, 5 and 15 minutes and where memory goes. Space pauses, `+` and `-` take a reading every
1, 2 or 5 seconds, `c` and `m` sort by CPU or by memory. Readings are only taken while the screen
is showing.

Without a terminal to draw on (a pipe, cron, `TERM=dumb`), or with `--count` or `--json`, it
prints one reading a line instead:

    bsweep live --every 5s --count 12
    bsweep live --json | jq .cpu      one stats Sample a line, as bsweep stats --json

`--every` is the time between lines (default 2s); `--count 0` keeps going until stopped.
`bsweep stats --json` and `--stream` now also carry `cores` (busy percent of each core),
`diskRead` and `diskWrite` (bytes a second, whole disks only) and each program's `pid`; all are
left out when empty, so older readers still work.

### Basic and Advanced

The CLI has two views, as the desktop apps do: **Basic** (the default) and **Advanced**. The
setting is saved for each person in `prefs.yml` beside `bsweep.yml` (your config folder, or
`/etc/bytesweep` for root), so it needs no `sudo`:

    bsweep advanced            says which is on, and where it is saved
    bsweep advanced on
    bsweep advanced off

In the app, `a` on Live switches it (and saves it), as do the **Advanced** row on Settings and the
`:` rows `advanced on`, `advanced off` and `live --detail`. `--detail` on `live` and `stats` uses
Advanced for that run; `--detail=false` uses Basic when Advanced is saved.

Advanced adds to Live, Basic stays as it was:

- **Every core** with its own figure and a history of its recent readings (the readings Live
  keeps, up to 240). Two columns put the cores under both, as many to a line as fit; a narrow or
  short window falls back to Basic's small bars, then leaves them out before the programs.
  Kinds of core are named only where the system says: macOS gives how many of each
  (`hw.perflevelN`, for example "2 super, 4 performance, 6 efficiency") but not which core is
  which, so the cores keep plain numbers; Linux names each core `P` or `E` from Intel's
  `/sys/devices/cpu_core` and `cpu_atom` lists, or from `cpu_capacity` when it has exactly two
  sizes; Windows and BSD name none.
- **Load over 1, 5 and 15 minutes**, where the system keeps one (`/proc/loadavg`, `vm.loadavg`);
  Windows keeps none, so Live shows Basic's line there.
- **Where memory goes**: the Memory bar is split into the system's own parts, with what each
  colour is, and the figures that overlap them:

| System | Parts in the bar | Figures |
|---|---|---|
| Linux (`/proc/meminfo`) | Used (MemTotal less MemAvailable), Can be freed (MemAvailable less MemFree), Free | Buffers, Cached, Shared, Available |
| macOS (`vm_stat`) | Apps (anonymous less purgeable), Wired, Compressed, Cached files (file-backed and purgeable), Free | |
| Windows (`GetPerformanceInfo`) | In use, Available | System cache, Committed of the commit limit |
| FreeBSD (page queues) | Active, Inactive, Laundry (or Cache before 11.2), Wired, Free | Buffers |

  Swap stays its own line, used of its total. A part the system doesn't give is left out, never
  worked out from a guess; other BSDs get the load averages only.

`bsweep stats --detail` prints the same, once; `bsweep live --detail --count N` adds a second line
to each reading. With `--json` they carry `loads` ([1, 5, 15 min]), `memory` (each part's `name`,
`bytes`, `bar` when it is part of the bar, and `of` for a limit), `tiers` (`name`, `cores`) and
`coreKinds` (each core's kind, only where the system says which is which). A Basic reading leaves
them all out. On a Mac, `cores` now comes from `host_processor_info` (called without cgo), so a
release build shows every core, in Basic too.

## Every command from the app

In the app, `:` or Ctrl+P lists every command, grouped, with a filter. Enter runs the chosen
one. Commands with a screen of their own open it; commands that need values (a path, a host, a
size) ask for them in a small form that shows the command line it will run. The command runs as
the same `bsweep` program, so its administrator and safety checks all apply, and its
output is shown in the app. A command that changes something shows its dry run or preview first
(`--dry-run`, `--preview`, `--check`) and runs for real only after Enter; one with no preview asks
first with the exact command line. `connect` takes over
the terminal until it ends; `manage`, `host list` and `log` open their screens (Servers, History). Linux-only commands are marked and can't be chosen elsewhere.
Typing a row's whole name, such as `logs clear`, picks that row.

Every option the command line has is reachable from the app, as a palette field or a screen key:
a test (`TestEveryFlagIsInTheApp`) fails the build for any flag or sub-command that tab completion
offers and the app can't reach. Only `--json`, `-0`, `--bytes` and `--count` are left
out, as they are for scripts. A few palette rows exist for options only:

    clean ID / clean --list / clean --older    by name; group by group; a group's unused items
    clean system, logs, containers, web ...    open that group on the Clean screen
    clean chats / clean privacy                Chats and Mail, Privacy traces on the Clean screen
    apps / apps leftovers                      the list, and what removed apps left
    apps remove / apps clean                   its dry run first, then Enter; apps clean is leftovers clean, --all for every one
    rescue options                             --disk (picked from the disks), --target, --hard
    logs clear / schedule logs / remove        --older, --docker, --live, --webhook
    report save                                report --json to a file, for diff
    sync --watch / sync-undo put               keep syncing until Esc; put back one file
    host edit / folder edit / remove           every field as the command line takes it
    check, metrics, grown, dupes PATH, fleet   --warn --crit --webhook, --out, --days, --limit --all-disks, --file
    compress, archive, archive bring-back      their dry run first; --older, --to; list and where show the record
    permissions --kind                         one kind, picked from the list; --used
    undo free                                  free --all, or --older when the field is filled; dry run first
    Remove now, no Undo (a switch)             --now on rm, dupes --keep, clean ID, clean --older, apps, tidy, compress

## Keys on each screen

| Screen | Keys |
|---|---|
| Clean | Enter opens a group, Esc or Backspace goes back (← → always change the tab), Space ticks, `a` Select all, `n` Deselect all, `o` not used in, `c` cleans; when something ticked would go to Undo, the question offers `F` Remove now (`clean --now`) |
| Explore | Enter opens, Esc or Backspace goes back (← → always change the tab), Space marks, `a` / `n`, `c` cleans (the question: Enter Clean, to Undo; `F` Remove now, `rm --now`), `/` filters by name, `i` sorts by number of files (`top --inodes`), `f` the largest files under the folder (`top --files`), `F` find by size, age and name (`find`): the results list here, to mark and clean, Esc goes back. A Grew column shows what grew since yesterday when the daily record has it |
| Held | Enter empties a held log |
| Undo | Enter puts back, `f` frees the chosen one now, `F` frees all (`undo free --all`) |
| Logs | Space ticks, `a` / `n` (the part the cursor is in), Enter clears, `o` days kept, `d` container logs (`--docker`), `l` live logs (`--live`), `s` new schedule; in Schedules, Space ticks and `x` stops the ticked ones or the chosen one |
| Transfer | Enter syncs (changes first), Space ticks, `a` / `n`, `+` adds a folder pair (or a share, in that part), `e` changes one, `x` removes the ticked ones, `w` keeps syncing until Esc (`sync --watch`), `u` lists what a sync removed and Enter puts one back (`sync-undo --restore`), `b` browses both sides |
| Live | Space pauses, `a` Advanced or Basic (`advanced on`/`off`, `live --detail`), `+` `-` pace, `c` `m` sort, `s` stops the chosen program (`stop`), `h` what the monitor recorded (`stats --history`) |
| Duplicates | Enter opens, Esc or Backspace goes back (← → change the tab), Space ticks, `a` / `n`, `k` keep rule, `c` cleans (the question: Enter Clean, to Undo; `F` Remove now, `dupes --now`), `r` again, `d` next disk, `m` smallest file (`--min`: 1 MB, 10 MB, 100 MB, 1 GB, 64 KB), `o` other disks too (`--all-disks`) |
| Ports | `s` stops, and offers to stop at once (`--force`) what is still running after 5 seconds; `/` filters |
| Startup | `x` switches off or back on, `f` failed only, `s` the system's own items too (`--all`) |
| Sleep | `d` how far back (`--days`: 7, 14, 30, 1, 3), `w` only what keeps it awake (`--now`), `s` the system's own holds too (`--all`), `r` reads again |
| Permissions | `t` one kind at a time (`--kind`), `u` only what has a last use or is in use now (`--used`), `r` reads again |
| ShareSafe | `f` medium and high only (`--risky`), `s` what is off and the system's own ports too (`--all`), `r` reads again, Enter repeats where to switch the chosen item off |
| History | Enter goes to the change in Undo while it is there, `o` looks further back (30, 7, 1, 90, 365 days), `r` reads again |
| Servers | The fleet table. Enter opens the full app on it (`connect`), Space ticks, `a` / `n`, `s` sorts (name, fullest disk, updates, problems: `fleet status --sort`), `T` shows one tag at a time (`--tag`), `#` sets the chosen host's tags (`host tag`), `+` adds, `e` changes, `x` forgets, `t` tests, `r` asks again. On the ticked servers: `c` clean-safe, `l` logs-clear, `u` updates-security, `U` updates-all, `M` maintain-run, `v` services-restart (offers a failed service): each server's own preview first, then Enter runs one server at a time and stops at the first failure, `F` keeps going (`--keep-going`) |
| Settings | Enter changes the chosen setting through its command, after one question; Advanced switches at once, as `a` on Live does |
| Health | Enter explains the chosen finding (what it means, what can happen, what to do) and, when ByteSweep can fix it, offers the fix: its preview first, then Enter again; `r` checks again |
| Maintenance | Enter does what the row says (changes the plan or the window, runs the plan, restarts a failed service, sets or cancels a restart), `p` plan, `w` window, `u` run the plan now, `x` switches the chosen plan or window off, `r` reads again |
| Backups | Enter on a backup backs it up now (`backup run ID`, preview first), Enter on a copy opens the restore form (into an empty folder), `+` sets up a backup (`backup add`), `s` lists the chosen backup's copies (`backup list`), `c` checks it (`backup check`), `x` removes it (`backup remove`, with `--forget-data` as a choice), `i` installs restic, `r` reads again |

`ci --dry-run` lists what `ci` would clean, in order, and cleans nothing.

## Remove now (no Undo)

Everything that goes to Undo can instead be removed at once, with the same flag everywhere:
`--now`, "space back now, no Undo". The space comes back straight away, and nothing can put it
back. The same protection runs first (system folders, databases, the keep list, a group's last copy are still refused).

| Command | What `--now` removes at once |
|---|---|
| `rm PATH` | the path |
| `dupes --keep RULE` | the extra copies; one of each still stays |
| `clean ID...` (and `--group`, `--older`, `--safe`) | the items that go to Undo: privacy traces, chats' files, an Android emulator's folders. Every other item is removed for good already |
| `apps remove NAME` | a Mac app bundle (a package manager's removal has no Undo) |
| `apps leftovers clean` | the leftover folders (kept settings are purged for good already) |
| `tidy` | the files tidy picks |
| `compress` | each original, right after its `.gz` is read back and matches it byte for byte |

`archive` has no `--now`: it already frees the original once the copy on the other disk is
checked file by file, with that copy as the safety net.

Without `--yes` every `--now` asks first, saying the size and that it can't be undone. With
`--dry-run` it says it would remove now. `--json` says `"undo": false` for these runs.

    sudo bsweep rm /srv/old.tar --now
    sudo bsweep dupes /srv --keep newest --now --dry-run
    sudo bsweep clean shell-history@root --now
    bsweep tidy --now

To empty Undo itself:

    sudo bsweep undo free ID                 one entry
    sudo bsweep undo free --all --dry-run    what would go
    sudo bsweep undo free --all              everything in Undo, after one question
    sudo bsweep undo free --older 3d         only what was cleaned 3 days ago or more

In the app, every question before something goes to Undo has two answers: Enter is
**Clean (Undo 7 days)**, the default, and `F` is **Remove now (no Undo)**, never the default.
The `:` rows that use Undo have a "Remove now, no Undo" switch, off until you switch it on, and
their run says it can't be undone before Enter. On the Undo screen `F` frees everything.

## Clean, by group

The app's Clean screen (key `2`) lists groups first: Quick clean (every safe item), System, Logs,
Developer packages, AI models, Containers, Web apps, Chats and Mail, Privacy traces, Databases and
Snapshots, each with its size,
how much of it is safe, and how many items are ticked. Enter opens a group; Esc or Backspace goes
back. Space ticks a row, or on the list of groups every safe item in that group. `a` is Select
all and `n` Deselect all: inside a group for what it shows, on the list of groups for everything
safe. `o` steps through "not used in: any time, 30 days, 90 days". Ticks are kept across groups,
and `c` (or Enter inside a group) shows every ticked item, from every group, before it runs.

Developer packages has one row per tool: npm, Yarn, Bun, Deno, pnpm, pip, uv, Poetry, Conda, Go
build and module caches, Cargo, Gradle, Maven, NuGet, Composer, Homebrew, CocoaPods, Xcode
DerivedData, device support and old simulators, Playwright and Puppeteer browsers. Where the
tool is installed for that person it cleans its own cache (`npm cache clean --force`, `pip cache
purge`, `go clean -cache`, `brew cleanup -s`, ...); otherwise the cache folder goes. Run as root,
a tool runs as the person who owns the folder, never as root in their home, and only a tool from
their home or the system's folders is used. Xcode Archives are explained, never removed.
`node_modules` and Python virtualenvs are offered only inside projects nothing has changed for 90
days, never in one a running program works in (Linux), and never ticked for you.

AI models has one row per model: Ollama (by name, freeing only layers no other model shares;
removed with `ollama rm`, and only when the running Ollama keeps its models in that folder),
Hugging Face hub repos and datasets (`HF_HOME` and `HF_HUB_CACHE` are followed), LM Studio, the
PyTorch hub and Whisper caches, and Stable Diffusion checkpoints inside ComfyUI or the web UI's own
model folder. None is ever safe. An Ollama model with no licence from the Ollama library is marked
as made here, since it can't be downloaded again.

Containers has the Docker, Podman and Kubernetes rows, and one row per virtual machine, profile,
box or emulator, with what that tool's own commands can clean. macOS: Docker Desktop, OrbStack,
Rancher Desktop, Colima (per profile), Lima (per instance), Podman machines, Multipass, Parallels,
VMware Fusion, VirtualBox, Tart, UTM, VirtualBuddy, Vagrant boxes, minikube and Android emulators.
Linux: rootless Docker, Podman machines, Colima, Lima, QEMU / libvirt and GNOME Boxes disks, LXD and
Incus (looked at only), VirtualBox, VMware, Multipass, minikube, Vagrant and Android emulators.
Windows: Podman machines, Rancher Desktop, Hyper-V disks, VirtualBox, VMware Workstation, Multipass,
minikube, Vagrant and Android emulators. Each tool's setting for where it keeps machines is followed
(`COLIMA_HOME`, `LIMA_HOME`, `TART_HOME`, `VAGRANT_HOME`, `MINIKUBE_HOME`, `ANDROID_AVD_HOME`,
`ANDROID_USER_HOME`, `ANDROID_SDK_HOME`, `XDG_DATA_HOME`, `XDG_CONFIG_HOME`). A machine's size is the
space its disks really take (a sparse 60 GB disk holding 20 GB counts 20 GB), with what it can grow
to beside it.

- Safe, ticked for you: build cache (`docker --host SOCKET builder prune --all --force`) and giving
  free space back to the disk (`colima ssh -p NAME -- sudo fstrim -a`, `limactl shell NAME sudo fstrim
  -a`, `podman machine ssh NAME sudo fstrim -a`, `rdctl shell sudo fstrim -a`), only while the
  machine runs.
- Review, never ticked: unused images and stopped containers of that engine, older versions of a
  Vagrant box (`vagrant box prune`), an emulator's saved quick-boot states (to Undo).
- Remove the whole machine (`colima delete NAME --data --force`, `limactl delete NAME`, `podman
  machine rm --force NAME`, `multipass delete --purge NAME`, `tart delete`, `minikube delete
  --profile`, `vagrant box remove NAME --all`, `prlctl delete`, `vmrun deleteVM`, `VBoxManage
  unregistervm NAME --delete`): can't be undone, except an Android emulator, which goes to Undo. It
  is never ticked for you, never picked by `--safe`, `--older` or Select all (`a`), only ticked on
  its own or named (`bsweep clean colima:default:remove`), and refused while the machine runs.
- Explained only: apps with no command ByteSweep uses (UTM, VirtualBuddy, Docker Desktop's and
  OrbStack's own reset, Hyper-V, libvirt, GNOME Boxes, LXD), with how to remove one in the app.

Volumes are never pruned. An engine that isn't running is skipped, never started, and whether a
machine runs is read again just before anything runs. When a whole machine is removed, what was
ticked inside it is left out. Commands run as the person who owns the machine, never as root in
their home. IDs are the tool, the machine and what is cleaned: `colima:default:trim`,
`lima:ubuntu:remove`, `docker-desktop:build-cache`, `avd:Pixel_8_API_35:snapshots`; run as root,
another person's machine ends in `@name` (`colima:default@alice:trim`).

    bsweep clean --list                        every group, with how long since each was used
    bsweep clean --list --group ai --json      one group; items carry group and lastUsed
    bsweep clean --group dev --safe --dry-run
    sudo bsweep clean --group ai --older 90d   models nothing read for 90 days; asks first
    sudo bsweep clean ollama:llama3:70b hf:org/name node-modules:/srv/old-app
    bsweep clean --list --group containers --json   machines carry machine, oneByOne and undo
    bsweep clean lima:old-vm:remove            one whole machine, after one question

`--older` keeps anything used more recently, and an item that can't say when it was used is never
counted as old. With `--group` it picks every cleanable item in that group, Review ones too, so it
always asks first unless `--yes` is given; removing a whole machine is never picked this way.
`dev-caches` still works as a name: it picks every safe developer cache.

Chats and Mail has what chat, meeting and mail apps keep in each home, the same table as the
desktop apps' Chats and Mail page, with the Flatpak (`~/.var/app/ID`) and Snap (`~/snap/NAME`)
copies on Linux. It is split the same way:

- Review, never ticked for you: copies the app downloads again. Slack, Microsoft Teams, Discord and
  Element caches (Linux and Windows; Discord and Element on macOS too), Thunderbird's saved
  previews, Apple Mail's copies of attachments you opened (to Undo). Each is refused while its app
  runs: quit it first.
- Manual, never ticked for you and never picked by `--older` or Select all, only ticked on its own
  or named: what may be the only copy. Files you saved from Telegram, Zoom meetings you recorded,
  Apple Messages attachments (needs Full Disk Access for the terminal). They go to Undo.
- Explained only, measured and never removed: Signal, WhatsApp, Telegram's own media cache, Slack
  and Teams on macOS, Outlook's .ost and .pst files and new Outlook's store, stored Mail and
  Thunderbird mail. Each says how to make it smaller inside the app.

Privacy traces has, for each home: terminal command history (bash, zsh, fish, sh and ksh; PowerShell
on Windows), Python, Node, MySQL, PostgreSQL, SQLite and less history, the recently opened files
list (`recently-used.xbel`, KDE's RecentDocuments, macOS's recent documents, Windows' Recent and
Office's recent shortcuts), picture previews (`~/.cache/thumbnails`, Windows' thumbcache), and
editor backups of unsaved work (VS Code, VSCodium, LibreOffice, Vim and Neovim swap files, Emacs
auto-save lists; refused while one of those editors runs). Every row is Review: never safe, never
ticked for you, and each says what it clears ("Clears your command history: ..."). Histories,
recent lists and backups go to Undo; previews are made again, so they go for good.

IDs say whose they are: `slack@alice`, `telegram-downloads@alice`, `shell-history@root`,
`editor-backups@alice`. The name after `@` is the home folder's, made safe to type: lower case,
with spaces and shell characters as dashes, so `C:\Users\Alex morgan` gives `teams@alex-morgan`
(the title keeps the real name). Two homes that come out the same get a short code added. The
name as it was typed before still works: `bsweep clean 'teams@Alex morgan'`.

    bsweep clean --list --group chats
    sudo bsweep clean slack@alice discord@alice
    sudo bsweep clean zoom-recordings@alice      the only copy: named on its own, to Undo
    bsweep clean --list --group privacy --json
    sudo bsweep clean shell-history@root app-history@root

## Screens without a number key

Keys 1 to 9 and 0 open the first ten screens. Duplicates, Ports, Startup, Sleep, Permissions,
ShareSafe, History, Servers, Settings, Maintenance and Backups come after Live: Tab and Shift-Tab reach them, as do a
click on the sidebar and the `:` list (`dupes`, `ports`, `startup`, `sleep`, `permissions`,
`sharesafe`, `log`, `manage`). In a narrow window the row of
screens scrolls so the chosen one shows.

Duplicates, Ports and Startup follow Clean's rules: a change asks first, and a change to the
whole system needs an administrator. Your own programs, user units, crontab and autostart files
need no `sudo`.

## Duplicates

`bsweep dupes [PATH...]` finds files and folders that are copies of each other, as the desktop
app does: files of the same size, then the first and last 64 KB, then the whole file, only for
those still alike. Files under 4 KB are never shown (`--min`, default 1 MB, raises the bar).
Hard links and clones of one file are one copy on disk, so cleaning one frees nothing: they are
marked "same file as" and never counted as space to save. A folder whose whole contents match
another is one row, not one per file, and only the top of a copied tree is shown. Hidden things
and build output (node_modules, target, vendor and the like) are not compared; protected folders,
the Undo store, the config's keep list and other disks (unless `--all-disks`) are never looked in.

    bsweep dupes                              the fullest disk
    bsweep dupes /srv --min 10M --json        groups, largest saving first
    bsweep dupes /srv --keep newest --dry-run what would go, and which copy stays
    sudo bsweep dupes /srv --keep oldest --yes

`--keep newest|oldest|shortest` picks the copy that stays; ties go to the one that reads as the
original over "name copy" or "name (1)", and one filed away over one in Downloads. The rest go
to Undo for 7 days, like `rm`, so the space comes back when Undo ends; `--now` removes them at
once instead (space back now, no Undo). One copy of every group
always stays: before anything moves, every group is checked, overlapping ones included, and a
copy that changed since the search is left alone.

In the app, the Duplicates screen searches the disk Explore shows when it is first opened, with
a progress bar. Enter opens a group; Space ticks a copy (never the last one); `a` Select all and
`n` Deselect all; `k` changes which copy stays; `c` cleans what is ticked after one question;
`r` looks again; `d` tries the next disk. Nothing is ticked until you tick it.

## Compress

`bsweep compress PATH... [--older 30d]` compresses logs, dumps, backups and data text with gzip,
where it saves space. Inside a folder it takes rotated logs (`app.log.1`, `syslog.2`,
`messages-20261101`; never a log a program still writes by that name, like `app.log` or `syslog`,
unless you name that file), dumps (`*.sql`, `*.dump`, core files), backups (`*.bak`, `*.old`, `*.tar`)
and data text (`*.csv`, `*.tsv`, `*.txt`, `*.jsonl`); a file you name is taken whatever it is.
`--older` takes only files not changed for that long. It stays on one disk and never looks in
protected folders, the Undo store or `.git`.

These stay as they are, each with the reason: files compressed already (by name or by their
first bytes), files that would shrink by less than 10% (from a sample), files under 4 KB, files
written in the last 10 minutes, files a program has open (a live log keeps writing to the old
file, so those lines would be lost), databases, hard-linked files, and a file whose `.gz` is
there already.

    bsweep compress /var/log --older 30d --dry-run   each file, its size now and about after
    sudo bsweep compress /var/log /srv/dumps --older 30d
    sudo bsweep compress /srv/export.csv --yes
    bsweep compress ~/logs --older 30d          your own files need no sudo

The saving shows first. For each file, `NAME.gz` is written beside it under a temporary name,
flushed to the disk, read back and compared with the original by SHA-256, and given the
original's owner, mode and time. Only then does the original go to Undo for 7 days, like `rm`:
its space returns when Undo ends (`sudo bsweep undo free ID` frees it now; `--now` removes each
original right after the check instead, with no Undo). `sudo bsweep undo
restore ID` puts the original back and removes the `.gz`, if it is unchanged. If anything fails
or the run is stopped, the `.gz` is removed and the original stays.

## Archive to another disk

`bsweep archive PATH... --to DIR` moves files and folders to another disk and keeps a record of
where each went. DIR must be on a different disk: the same filesystem, another mount of the same
device, or (on Linux) another partition of the same physical disk is refused with the reason, as
is a folder in memory (tmpfs). There must be room for everything plus 16 MB, checked before
anything is written. Protected folders, the config's keep list, the Undo store, databases (by
name or by their first bytes, inside folders too), devices and sockets, and anything a program
has open are refused.

    bsweep archive /srv/old-projects --to /mnt/backup --dry-run
    sudo bsweep archive /srv/old-projects /var/backups/2025 --to /mnt/backup
    bsweep archive ~/Movies/2024 --to /Volumes/Backup     your own files need no sudo
    bsweep archive list
    bsweep archive where report-2025.csv
    bsweep archive bring-back 20261105-143012-ab12       sudo if the archive was made with sudo

Each archive goes to `DIR/bytesweep-archive/ID.part/`. Every file is hashed with SHA-256 as it is
read, written, flushed to the disk, then read back from the disk and hashed again. Owners, modes,
times and links are kept. The original is walked again: anything added or changed meanwhile, or
opened by a program, stops the archive. Only then is the folder renamed to `ID/`, with
`manifest.json` (where it came from, with every file's checksum) beside the files in `data/`,
the record written on this system, and the original removed. A copy that fails or is stopped is
removed from the other disk and the original is untouched.

Run with sudo, the record is in `/var/lib/bytesweep/archive/` (`/var/db/bytesweep` on BSD, the
config folder on macOS and Windows); without, in your own `~/.config/bytesweep/archive/`, so a
person archives and brings back their own files with no sudo. One file per archive, with the disk's mount point, device, UUID and label. So
`list` and `where NAME` (an ID, a name, or any part of a path, files inside archived folders too)
answer with the other disk unplugged, and say whether it is connected. `bring-back ID` finds the
archive where it was written or at the same place on its disk mounted somewhere else, refuses if
something is now in the original's place or there is no room, copies it back under a hidden
name, checks every file against the checksum taken when it was archived, puts it in place, and
only then removes it from the other disk and the record. It needs root: they are your own files. `--dry-run` says what it would do and whether the disk is connected.

In the app, `:` lists `archive`, `archive list`, `archive where`, `archive bring-back` and
`compress`; each change shows its dry run first and runs after Enter.

## Ports

`bsweep ports` lists what is listening: the port, whether other computers can reach it ("open to
the network") or only this one, the program, its PID and user, how long it has run, CPU and
memory, and what it is: a dev server and its project (named from package.json, pyproject.toml,
go.mod and the like), a Docker container by name, or a systemd service. Without root, other
users' programs show as `?`.

    bsweep ports
    bsweep ports --open             only what other computers can reach
    bsweep ports stop 3000          by port, or by PID
    bsweep ports stop 5173 --force  at once, no chance to save
    bsweep ports --json

Stopping asks each program to close (SIGTERM; taskkill on Windows), waits 5 seconds, then offers
to stop what is left at once. A dev server stops with the rest of its project: its other servers,
what they started, and the `npm run dev` or reloader that launched them, never the shell above.
A container's port stops the container (`docker stop`). sshd, PID 1, systemd's and launchd's own
programs, macOS's own listeners, Windows' critical processes (csrss, wininit, services, lsass,
smss, winlogon, svchost) and bsweep itself are never offered. Every stop is in `bsweep log`.

The app's Ports screen refreshes every 2 seconds while it shows; `s` stops the chosen row after
one question, `/` filters.

## Stop a program

`bsweep stop PID|NAME` stops any running program, not only one on a port. It is asked to close
(SIGTERM; `taskkill` on Windows) and has 10 seconds to save. What is still running then is ended
at once (SIGKILL; `taskkill /F`) only with `--force`, or when you say yes to the question. A name
is matched whole, without minding case, against the program's name and the file it runs; when it
matches several programs they are all listed, and it asks before stopping all of them (`bsweep
stop PID` stops one).

    bsweep stop 4123
    bsweep stop node --dry-run       what it would stop, and what it leaves alone
    bsweep stop python3 --yes
    sudo bsweep stop 4123 --force    another user's program, ended at once after 10 seconds
    bsweep stop 4123 --json --yes    {"stopped", "stillRunning", "refused", "failed"}

Never stopped: PID 1, the kernel's own threads, sshd, your own shell and the session around it,
systemd's and launchd's own programs, Windows' critical processes and bsweep itself. A service's
own program isn't stopped either, since its manager would start it again: the right command is
shown instead (`sudo systemctl restart nginx.service`, `systemctl --user ...`, `launchctl kickstart
-k`, `Restart-Service`). A program a service started, such as a worker or a cron job, can be
stopped on its own. Like `ports stop`, your own programs need no `sudo`,
another user's do. It exits 3 when nothing could be stopped, or something is still running. Every
stop is in `bsweep log`.

On the app's Live screen, `s` stops the chosen program after the same question, and offers to end
it at once if it is still running after 10 seconds. `stop` in the `:` list takes a PID or a name.

## Updates

`bsweep updates` lists the updates waiting, security fixes first, from the system's own package
tool, and says whether a restart is needed: `/var/run/reboot-required` (and the packages that asked
for it), `needrestart`, `needs-restarting`, `zypper needs-rebooting`, a running kernel whose
modules were replaced, and Windows' pending restart (the registry and the Windows Update Agent). Services still running replaced files are
named, with the `systemctl restart` that is enough for them; dbus, systemd-logind, display
managers, Docker and systemd itself are named for the next restart of the computer instead, since
restarting them can end logins or running containers. Run as root, it reads fresh package
lists first (`apt-get update`, `zypper refresh`, `apk update`, `pkg update`); without, it says the
lists are the ones already there. On macOS and Windows the system's own updates are one more
source: Apple's Software Update and Windows Update. Both ask over the network and can take half a
minute or more, which the command says while it waits; every tool is asked at once. Looking is free.

    bsweep updates
    bsweep updates --security                  security fixes only
    sudo bsweep updates install --dry-run      the exact commands, run nothing
    sudo bsweep updates install --security
    sudo bsweep updates install --yes
    bsweep updates --json

| Tool | Lists with | Installs with | Security only |
|---|---|---|---|
| apt | `apt list --upgradable` (security: a `-security` suite) | `apt-get -y --with-new-pkgs upgrade`, keeping your config files, `NEEDRESTART_MODE=l` | `apt-get install --only-upgrade` the security packages |
| dnf, yum | `check-update`, `updateinfo list --security` | `dnf -y upgrade` | `dnf -y upgrade --security` |
| zypper | `list-updates`, `list-patches --category security` | `zypper -n update` | `zypper -n patch --category security` |
| pacman | `checkupdates`, or `pacman -Qu` | `pacman -Syu --noconfirm` | not marked: left alone |
| apk | `apk version -l '<'` | `apk upgrade` | not marked: left alone |
| pkg (FreeBSD) | `pkg version -vRl '<'`, `pkg audit` | `pkg upgrade -y` | `pkg upgrade -y` the vulnerable packages |
| flatpak, snap | `remote-ls --updates`, `refresh --list` | `flatpak update -y`, `snap refresh` | not marked: left alone |
| Homebrew | `brew outdated --json=v2` | `brew upgrade`, as the person who owns Homebrew, never as root | not marked: left alone |
| winget | `winget upgrade`; found inside `Program Files\WindowsApps` when it isn't on PATH (the SYSTEM account, services, SSH) | `winget upgrade --all --silent` | not marked: left alone |
| macOS (Software Update) | `softwareupdate -l`, each marked when it needs a restart | `softwareupdate -i -a`, as root, never with `-R` | `softwareupdate -i` the labels Apple names as security fixes (Background Security Improvement, Security Response, XProtect, MRT, Gatekeeper data); a macOS update holds security fixes too but isn't marked, so it is left alone and said so |
| Windows Update | the Windows Update Agent (`Microsoft.Update.Session`, `IsInstalled=0 and IsHidden=0`), each marked when it needs a restart | the same agent downloads, then installs, as administrator; it never restarts | the updates with an MSRC severity, in Security Updates, or Defender's definitions |

`install` shows every update and the exact command line before anything runs, then asks; `--yes`
skips the question, and with `--json` nothing runs without `--yes`. It needs root for the system's own tools (Homebrew and winget run as you). Before it runs, it looks for a package
tool's lock someone else holds (dpkg's and apt's lock files, the rpm database, dnf's, yum's and
zypper's PID files, pacman's `db.lck`, apk's lock) and, instead of waiting, says which program holds
it, by name, PID and command line; a pacman lock nothing holds is called left over. apt runs with
`DPkg::Lock::Timeout=0`, so it stops rather than waits if a lock is taken in between. Ctrl+C reaches
the package tool itself, which stops safely. ByteSweep never restarts the computer, nor any service:
it says when a restart is needed and which command does it. Every install is in `bsweep log`. It
exits 3 if a tool failed or a lock is held.

macOS: on Apple silicon `softwareupdate` may ask for an owner's password, as System Settings does;
an update that needs a restart is installed and waits for you (Apple menu, Restart). Windows:
installing through the Windows Update Agent doesn't work over SSH or a remote session (access
denied, 0x80070005), so run it in a terminal on the computer opened as administrator, or as
SYSTEM; Windows may still pick its own restart time, as after any update. As SYSTEM, a winget
that can't run says so instead of being skipped.

In the app, `updates`, `updates --security` and `updates install` are in the `:` list; install
shows the dry run first, and runs after Enter. The Health screen's update findings point here.

## Startup

`bsweep startup` lists everything that starts by itself, in two groups: what opens when you log
in, and what runs in the background. Failed items come first, with the command that says why
(`journalctl -u NAME -n 50`); Health lists them too. Items the system needs (systemd's own,
networking, SSH, cron, Apple's and Microsoft's) are left out unless they failed, like the
desktop app's "Show macOS items"; `--all` shows them, marked `(system)`. They are never switched
off. On macOS, `--all` also reads Apple's own jobs in /System/Library, which takes a few seconds.

    bsweep startup
    bsweep startup --all                         the system's own items too
    bsweep startup --failed
    sudo bsweep startup off nginx.service
    sudo bsweep startup on nginx.service
    bsweep startup off user:syncthing.service    your own unit: no sudo
    bsweep startup off cron:3c1c41cc             an @reboot line in your crontab
    bsweep startup --json
    bsweep startup off login:findow              macOS: a Login Item, no sudo

| System | What is listed | What off does |
|---|---|---|
| Linux | systemd services and timers (enabled, failed, masked), your user units, cron @reboot, ~/.config/autostart | `systemctl disable --now`; the crontab line is marked `#bsweep-off`; the autostart file moves to ~/.config/bytesweep/autostart-off |
| macOS | your Login Items (the apps that open at login), your Launch Agents, Launch Agents for all users (shown only), Launch Daemons; with `--all`, the items allowed in the background (shown only) | a Login Item is taken out through System Events, and put back with the same app and hidden flag; `launchctl bootout` and `launchctl disable`; the file stays |
| Windows | auto-start services, Run keys, Startup folders, tasks at logon or startup | `sc config start= demand`; a Run value moves to HKCU or HKLM\Software\ByteSweep CLI\Run off; a shortcut moves aside; `schtasks /disable` |
| BSD | rc.conf `_enable` lines | shown only: `sysrc NAME_enable=NO` |

Each switch is written down before it is made, in `/etc/bytesweep/startup-changes.json` (the
settings folder on macOS and Windows), or in your own settings folder (`~/.config/bytesweep/startup-changes.json` on Linux) when you
switch your own things off without `sudo`. `bsweep startup on ID` puts back exactly what was
there, including starting a service that was running. Only what ByteSweep switched off can be
switched on here.

On macOS, the Login Items are those in System Settings, General, Login Items & Extensions,
under Open at Login, read through System Events (IDs like `login:findow`). The first time,
macOS may ask whether your terminal may control System Events; if it isn't allowed, or doesn't
answer within 15 seconds, the list says so and how to allow it (Privacy & Security,
Automation), and the rest is listed as usual. An app that added itself through macOS's own
login API has no path in System Events, so it is shown only: switch it off in the app, or in
System Settings. The items under Allow in the Background (helpers, agents and background tasks
apps register with macOS, IDs like `btm:com.utmapp.UTM`) come from `sfltool dumpbtm`, which
takes a few seconds, so they are read only with `--all` (and `s` in the app); they are shown,
never switched off, as only System Settings changes them. Where macOS lets only an
administrator read that list, `sudo bsweep startup --all` reads it. The maker is read from the
app's signature (`codesign`), else from its bundle identifier. What couldn't be read is said
after the list, and on stderr with `--json`, so the JSON stays a plain list.

The app's Startup screen shows both groups; `x` switches the chosen row off, or back on, after
one question, `f` shows only what failed, and `s` adds the system's own items (`--all`).

## Sleep

`bsweep sleep` answers "why did my computer wake up, and what is keeping it awake?". It lists
what holds the computer or its screen awake right now, then each sleep in the last 7 days
(`--days N`, 1 to 365), newest first: why it went to sleep, every time it woke by itself with the
screen off, and what woke it in plain words (the lid, the power button, a USB device, a Bluetooth
device, the network, Power Nap, a timer, the system's own upkeep). Then the wakes already planned
and the devices allowed to wake it. Each holder and each cause comes with what you can do; the
setting is named, never changed. A machine that never sleeps, as most servers, says "This machine
hasn't slept in the last 7 days." and lists when it was switched on or restarted.

    bsweep sleep
    bsweep sleep --days 30
    bsweep sleep --now        only what keeps it awake right now: no history, fast
    bsweep sleep --all        the system's own holds too, marked system
    bsweep sleep --json

| System | Sleeps and wakes | Keeping it awake | Planned, allowed to wake |
|---|---|---|---|
| macOS | `pmset -g log` (about a week): Sleep, DarkWake and Wake lines, the wake request macOS chose as it went to sleep, battery at each end | `pmset -g assertions`: apps holding the Mac or the screen awake; an app held by runningboardd is named | `pmset -g sched` |
| Linux | the journal: systemd-sleep, systemd-logind (lid, power and sleep keys) and the kernel's PM lines; a sleep that failed, and one it never came back from | `systemd-inhibit --list`: a block holds it off; a delay only makes sleep wait, so it counts as the system's own | `/proc/acpi/wakeup` (enabled devices), `/sys/class/wakeup` (how often each woke it), the RTC wake alarm |
| Windows | the System event log through `wevtutil`: Power-Troubleshooter 1 (each sleep and its wake source, a device, the power button or a scheduled task), Kernel-Power 506/507 (Modern Standby), Kernel-General 12 (start) | `powercfg /requests` | `powercfg /waketimers`, `powercfg /devicequery wake_armed`; `powercfg /lastwake` when the log doesn't say |
| BSD, Solaris, AIX | not read yet; says so | | |

No sudo is needed on macOS. On Linux, a user outside the systemd-journal and adm groups sees
only part of the journal; the report says so, and `sudo bsweep sleep` reads all of it. On
Windows, `powercfg /requests` needs an Administrator terminal; without one the rest still shows
and a note says what is missing. powercfg's own text is read in English; on another language
those parts give nothing rather than something wrong, and the event log reads the same in any
language. A wake reason the system wrote in words ByteSweep doesn't know is "the system didn't
say", with the raw words shown. It is free and changes nothing, so there is no `--yes`.

The app's Sleep screen (after Startup) shows the same parts; the chosen row says what to do.

## Snapshots

`bsweep snapshots` answers "where did my space go, when I already deleted the files?". A
snapshot is a copy of the disk as it was at one moment; what was deleted after that still takes
space until the snapshot goes. It lists every snapshot with its date, its own size when the tool
can say, and what made it, under its tool:

| System | Tools | Removed with |
|---|---|---|
| macOS | Time Machine local snapshots (`tmutil listlocalsnapshots /`); APFS snapshots (`diskutil apfs listSnapshots -plist`), such as the system update one | `tmutil deletelocalsnapshots DATE`. APFS: shown only, never removed |
| Windows | restore points (`Get-ComputerRestorePoint`), shadow copies and their storage (CIM, or `vssadmin list shadows` / `list shadowstorage`) | the System Restore API (`SRRemoveRestorePoint`); `vssadmin delete shadows /shadow={ID}`. `resize` runs `vssadmin resize shadowstorage` |
| Linux | Timeshift (`timeshift --list`), Snapper (`snapper --jsonout list`, each config), ZFS (`zfs list -t snapshot`), Btrfs subvolume snapshots not made by Snapper or Timeshift (`btrfs subvolume list -s`), LVM snapshots (`lvs`) | `timeshift --delete --snapshot NAME`, `snapper -c CONFIG delete N`, `zfs destroy pool/fs@snap`. Btrfs and LVM: explained, with the command to copy |

    bsweep snapshots
    bsweep snapshots --tool snapper
    sudo bsweep snapshots remove snapper:root:42 2026-11-01_10-00-01      shows what would go and asks
    sudo bsweep snapshots remove ID --yes
    sudo bsweep snapshots thin                       all but the newest of each, after a preview
    sudo bsweep snapshots thin --tool zfs --keep-newest 3
    sudo bsweep snapshots remove ID --keep-newest 0 --i-understand        the newest too
    bsweep snapshots resize --max 5%                 Windows, in an Administrator terminal
    bsweep snapshots --json

A snapshot may be someone's only way back, so nothing is ever picked for you and the newest of
each group (a Snapper config, a ZFS dataset, a Timeshift device, a drive) is kept unless you say
`--keep-newest 0 --i-understand`. A removed snapshot can't be put back: there is no Undo. The
Snapper snapshot the system started from is never removed. Sizes: ZFS and LVM always; Snapper and
Btrfs once quotas are on (`snapper setup-quota`); shadow copies only together, as the storage they
use; Time Machine, Timeshift and restore points can't say. Removing needs sudo (an Administrator terminal on Windows). Each removal is in `bsweep history`.

Clean's Snapshots group (`bsweep clean --list --group snapshots`) has one row a tool from the same
list, explained only. Health warns (`system.snapshots-hold-space`) when snapshots hold at least
2 GB and a twentieth of a disk that is 90% full, or may hold space on one 95% full.

The app's Snapshots screen (the last one) shows the same list: Space ticks one, `a` ticks all but
the newest of each, Enter shows each command before it runs, `t` thins (on a tool's heading, only
that tool), `k` changes how many of the newest are kept (0 asks first), `z` sets the shadow
storage limit on Windows.

## Permissions

`bsweep permissions` (or `bsweep perms`) lists which apps may use the camera, the microphone,
the screen, location, files and the rest: allowed or refused, since when, when last used where
the system records it, and what is using a camera or microphone right now. It only reads. Each
kind says where to switch it off; an app's row has the exact command where there is one.
Command history, recent files and other traces are a different thing: `bsweep clean --list --group privacy`.

    bsweep permissions
    bsweep permissions --kind camera     camera microphone screen location files accessibility input automation
                                         contacts calendar reminders photos bluetooth email messages phone
                                         notifications account background other (mic, cam, fda work too)
    bsweep permissions --used            only what has a last use, or is in use now
    sudo bsweep permissions              Linux: every program checked for a camera or microphone open now
    bsweep permissions --json

| System | Read from | Last used, in use now | Where to switch off |
|---|---|---|---|
| macOS | the TCC lists: `~/Library/Application Support/com.apple.TCC/TCC.db` and `/Library/Application Support/com.apple.TCC/TCC.db`, read only through macOS's own `sqlite3` | not recorded; the green or orange dot in the menu bar shows use | System Settings > Privacy & Security > the kind, with its `open "x-apple.systempreferences:..."` line; one app: `tccutil reset Camera BUNDLE-ID`, so it asks again |
| Windows | the consent store, `HKCU` (or each signed-in user's hive, run as SYSTEM) and `HKLM` `Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore`, through `reg query` | `LastUsedTimeStart` and `LastUsedTimeStop`; a stop of 0 is in use now | Settings > Privacy & security > the kind, with its `start ms-settings:privacy-...` line |
| Linux | Flatpak apps' sandbox (`devices=all`, `sockets=pulseaudio`, `filesystems=`) with their overrides, the portals' answers (`flatpak permissions`), Snap connections (`snap connections --all`) | programs with `/dev/video*` or a `/dev/snd` capture device open (`/proc/PID/fd`), apps recording through PulseAudio or PipeWire (`pactl list source-outputs`) | each app's own line: `flatpak override --user --nodevice=all ID`, `flatpak permission-set ...`, `sudo snap disconnect SNAP:PLUG`, `bsweep stop PID` |
| BSD, Solaris, AIX | nothing: these keep no list | | |

On macOS the lists are private: the terminal app needs Full Disk Access (System Settings >
Privacy & Security > Full Disk Access). Without it ByteSweep says it can't tell, never that
nothing is allowed; with only one list read it says some apps may be missing. Grants from the
machine's list are marked "every user"; an app no longer on the Mac is marked so. Location is
mostly kept outside TCC, so an empty Location says "not listed". On Windows, desktop apps (not
from the Store) are let in or kept out together, by one switch per kind, shown as a "Desktop apps"
row; each one is listed by name once it has used the camera or microphone. A kind switched off for
the whole computer (HKLM) is said once, and every app under it shows refused. Linux has no central
list: a program run outside Flatpak and Snap can use what your account can, and the list says so.
On a server with none of these it says so in one sentence. Without `sudo`, only your own programs
are checked for an open camera or microphone.

With `--json`, `kinds` has each kind shown (title, `allowed`, `inUse`, `switchOff`), `grants` each
app's row (`allowed`, `limited`, `inUse`, `lastUsed`, `since`, `everyUser`, `notFound`, `source`,
`service` (the system's own name), `switchOff` (the exact command, when there is one)), `notes` the
sentences above, and `cannotTell` is true when the list couldn't be read at all. Exit code 0.

The app's Permissions screen shows the same list, a heading per kind; the chosen heading says
where to switch it off, the chosen app its command. `t` steps through the kinds, `u` shows only
what was used, `r` reads again.

## ShareSafe

`bsweep sharesafe` (or `bsweep shared`) answers "What can people see?", like the desktop app's
ShareSafe: which folders this computer shares and with whom, which sharing services are on, which
ports other computers can reach, and whether the firewall is on. Each line has a risk and says
where to switch it off. It only reads: ByteSweep never changes sharing, SSH or a firewall, because
a wrong guess there locks people out.

    bsweep sharesafe
    bsweep sharesafe --risky        only medium and high
    bsweep sharesafe --all          also what is off, and the system's own ports
    sudo bsweep sharesafe --json    every item, for scripts

Exit 0 when nothing is medium or high, 1 for medium, 2 for high, so it works in monitoring.

| Risk | When |
|---|---|
| high | anyone on the network may change files with no password (a guest share that can be written, an NFS export to `*` with `rw` or `no_root_squash`); a database port open with no firewall, or published by Docker on every address; Telnet |
| medium | a guest share that can only be read; SSH that accepts passwords; screen sharing, Remote Management, FTP, WinRM, Webmin open to the network; a Docker-published port; Remote Desktop without Network Level Authentication; Windows letting File and Printer Sharing through on public networks; the firewall off while something is open |
| low | open to the network, but behind a password or a key: SSH with keys only, Samba shares for named users, an NFS export to one network, a web server, AirPlay Receiver, AirDrop for everyone |
| ok | only this computer reaches it, or only your contacts (AirDrop), or it is the system's own |

| System | What is read | Needs sudo for |
|---|---|---|
| Linux | `testparm -s` (or smb.conf) and folders shared from the file manager (usershares); /etc/exports and /etc/exports.d; sshd's settings (`sshd -T` as root, else sshd_config and its Include files); every listening port from /proc, with `rpcinfo` naming NFS's helpers; Docker's published ports; the firewall through Health's check (ufw, firewalld, nftables, iptables) | the usershares folder, program names, the firewall (without root only ufw's own setting and a running firewalld are read), SSH drop-ins only root may read, Docker when you aren't in its group |
| macOS | `sharing -l` (shared folders and guest access); File Sharing's guest switch; launchd's switched-on services (Remote Login, File Sharing, Screen Sharing) and their ports; Remote Management, Printer Sharing, Remote Apple Events, AirPlay Receiver; AirDrop and Media Sharing settings; /etc/exports; the firewall (`socketfilterfw`) | nothing; ports of other users' programs come from `netstat`, unnamed |
| Windows | one PowerShell call: Get-SmbShare and Get-SmbShareAccess (or `net share`), the Guest account, Remote Desktop and Network Level Authentication, OpenSSH Server, the firewall's profiles, the network's category (Public or Private), which profiles let File and Printer Sharing through, shared printers | who may open each share (Get-SmbShareAccess) |
| BSD | smb4.conf, /etc/exports (BSD format), sshd_config, ports, pf or ipfw in rc.conf | program names |

**Who can log in** is ShareSafe's fourth group: every account a person can log in to, and who can
become the administrator. HIGH: an account with no password at all, or a second account with user
number 0 (root's powers under another name). Medium: sudo without a password (cloud images give it
to their first user), an administrator account with a way in that hasn't been used for 90 days, and
on Windows an account Windows doesn't require a password for. Low: other administrators, and
accounts unused for 90 days. Service accounts (postgres, www-data) are left out unless someone can
log in to them, for example with an SSH key in their home. Linux reads /etc/passwd, /etc/shadow,
/etc/group, sudoers and sudoers.d (one allowed command is not counted as the keys to the machine),
and the newer of `lastlog` and `last`; macOS `dscl` and `last`; Windows Get-LocalUser and the
Administrators group by its SID. Passwords and sudoers need root; without it the group says so.
The fix is always advice: lock with `usermod -L -e 1` (nothing is removed), take NOPASSWD out with
visudo.

Folders that are set up but whose service isn't running (the Mac's Public folder while File
Sharing is off, a Samba share with smbd stopped) are listed as off, with `--all`. Docker's published
ports pass by ufw's and firewalld's rules, so a container port stays open with the firewall on;
the report says so.

The app's ShareSafe screen shows the same groups. `f` keeps medium and high, `s` shows
everything, `r` reads again; the line at the bottom says what the chosen item lets people do and
where to switch it off.

## Server checks

Six commands answer the questions a server's owner asks when something is off. All only read
(apart from their own records) and are free. Each has a row in the app's `:` list.

### Databases

`bsweep databases` (or `db`) finds MySQL and MariaDB, PostgreSQL (every data folder, every
version), MongoDB and Redis or Valkey, and says what fills the disk beside the data:

| Engine | What it looks at | What it says to do |
|---|---|---|
| MySQL, MariaDB | binary logs (in the data folder, or where `log_bin` points), relay logs, the general and slow-query logs, ibtmp1, undo tablespaces; each database's folder; as root it asks the server through root's own login (the socket on Debian and Ubuntu), never a password: `log_bin`, the expiry setting, whether replicas read from it | `PURGE BINARY LOGS BEFORE NOW() - INTERVAL 7 DAY`, then `binlog_expire_logs_seconds = 604800`; check a replica's position first; switch the general log off; restart to shrink ibtmp1 |
| PostgreSQL | pg_wal, the server logs (log_directory or /var/log/postgresql), the WAL archive folder read out of archive_command; as root it asks as the postgres account (peer login): each database's size by name, replication slots and how much WAL each holds, pg_stat_archiver | drop a slot whose replica is gone (`pg_drop_replication_slot`), fix a failing archive_command, trim the archive with the backup tool's own retention or `pg_archivecleanup` |
| MongoDB | the dbPath and systemLog.path from mongod.conf, diagnostic.data, the journal, old logs (MongoDB renames its log and never removes the old ones) | remove old logs, `logRotate: reopen` with a logrotate rule |
| Redis, Valkey | dir from every redis.conf: the snapshot, the append-only file (or appendonlydir), temporary files a save left | `BGREWRITEAOF` when the append file is far bigger than the data |

The daily timer keeps a size a day for every database, so later runs say how much each grows a
day and, when the disk is falling, how many days until it is full. Database files are never removed:
a binary log or a WAL file deleted by hand breaks replicas or the database itself. Databases inside
Docker volumes aren't looked at. Exit 0 fine, 1 warning, 2 bad.

### Sites

`bsweep sites` reads nginx (`nginx -T`, which follows every include; the usual files when nginx
isn't installed), Apache's virtual hosts and Caddy's Caddyfile, and lists each site: its names,
folder and size, certificate end date, logs and where it sends requests. It names: a folder that is
gone; a certificate that has ended, ends within 21 days, or whose file is missing (the web server
then refuses to start after its next restart); `proxy_pass` or `reverse_proxy` to a port on this
machine where nothing listens (visitors get 502); a log of 100 MB or more that no logrotate rule
covers, or more than 2 GB with its old copies; a name set twice for the same port. `--problems`
keeps only the sites with something wrong. Exit 0, 1 warning, 2 a broken site.

### Jobs

`bsweep jobs` asks whether the scheduled jobs ran. systemd timers: the last run's result and exit
code from the service it starts, a timer that was due an hour ago and hasn't run, a timer whose
service doesn't exist. Every crontab line (/etc/crontab, /etc/cron.d, /var/spool/cron for people's
own): the schedule is worked out minute by minute, and the journal's `CRON ... CMD` lines say
whether it ran when it was due (a job due before the machine started isn't missed; when cron
doesn't log to the journal, nothing is judged); a job whose program is gone; output thrown away
because no mail server takes it, so its errors went unseen (the fix appends `>> /var/log/NAME.log
2>&1`). On Windows the tasks people and apps added (not \Microsoft\), by LastTaskResult and missed
runs; apps' own updaters are shown only when they fail. macOS's launchd jobs that failed are in
Health. The system's own timers that are fine, and switched-off ones, show with `--all`.
Exit 0, 1 a missed run or lost output, 2 a failed job or a missing program.

### Logins

`bsweep logins` reads sshd's lines from the journal (or /var/log/auth.log, /var/log/secure) for the
last 7 days (`--days`): who logged in, how many times, from where, with a key or a password; failed
tries grouped by address with the names they tried (one connection counts once), and whether a
guessing address later got in. Then every key in every account's authorized_keys, service
accounts too, with the options that limit it. The first run as root writes the keys down
(known-keys.json in ByteSweep's data folder, root only); after that a key nobody wrote down is
**NEW**, `bsweep check` turns critical with a `CRITICAL new SSH key` line, and alerts tell it.
`bsweep logins accept` says the keys there now are yours. On macOS and Windows only the keys are
checked (Windows: also administrators_authorized_keys). Exit 2 a new key, 1 root logged in with a
password or a guessing address got in, else 0.

### Before and after

    sudo bsweep before                 write down services, ports, packages, kernel, disks
    sudo apt upgrade
    sudo bsweep after                  what changed; exit 1 if something stopped

`after` names services that stopped, started, newly failed or were mended; ports that closed or
opened and what listened; packages changed (old → new), added and removed; a new kernel that isn't
running yet; whether a restart is waiting now or was already; and disks whose use moved by more
than 100 MB. `--name` keeps several records; `before --list` lists them. Packages come from the
same lists as `bsweep apps`; services from systemd, launchd or `sc query`.

## Alerts

    sudo bsweep alerts add slack --url https://hooks.slack.com/services/...
    sudo bsweep alerts add discord --url https://discord.com/api/webhooks/...
    sudo bsweep alerts add telegram --token 123456:ABC --chat 987654
    echo PASS | sudo bsweep alerts add email --to ops@example.com --smtp smtp.example.com:587 --user ops@example.com --password-stdin
    sudo bsweep alerts add email --to ops@example.com          through this machine's sendmail
    sudo bsweep alerts add webhook --url https://example.com/hook
    sudo bsweep alerts test [ID]
    sudo bsweep alerts on --every 30m --full-days 3 --cert-days 14
    sudo bsweep alerts run --dry-run   what would be told now, sending nothing
    sudo bsweep alerts                 places, on or off, what is still open
    sudo bsweep alerts remove a2
    sudo bsweep alerts off

`alerts on` installs a timer (systemd, launchd, Task Scheduler or cron) that runs `bsweep alerts
run`. Each run works out: disks past the warn and crit limits in config.yml, disks full within
`--full-days` at their pace (needs the daily record: `bsweep timer on`), failing or worn drives,
failed, missed or gone scheduled jobs, certificates ending within `--cert-days` (sites and every
Let's Encrypt certificate), broken sites, databases' bad findings, failed systemd services, and SSH
keys nobody wrote down. A problem is told once when it starts (again if a warning turns critical)
and once when it is over; a number that moves inside it ("holds back 1.2 GB" then "1.3 GB") is the
same problem. If no place takes a message, it is tried again next run.

| Place | Sent as |
|---|---|
| slack | an incoming webhook: `{"text": ...}` |
| discord | a channel webhook: `{"content": ...}`, cut at 1,900 characters |
| telegram | the Bot API's sendMessage to `--chat` |
| email | SMTP with STARTTLS (587), TLS from the start (465), or sendmail when there is no `--smtp` |
| webhook | `{"text", "host", "subject", "body"}` |

Settings are in alerts.json in ByteSweep's config folder, readable by root only, because it holds
tokens and mail passwords; `alerts --json` shows them as "set". The older `--webhook` on check, auto,
schedule and config.yml's `webhook` still work on their own. In the app, `:` alerts lists every
row; a mail password can only be given through `--password-stdin`, so it never shows on a screen.

When `databases`, `sites`, `jobs`, `logins` or `check` (in a terminal) find something and alerts
are off, their last line says how to be told next time: `sudo bsweep alerts on`. Never with
`--json`, never when `check` is piped into monitoring, never once alerts are on.

Alerts can also watch backups: `sudo bsweep alerts add backups --hours 26` tells every place when
the newest good backup is older than that (critical when it is twice as old, or there is none);
`alerts remove backups` stops it.

## Clock and names in Health

Health also checks, on every system, that names resolve (two names failing means the resolver,
not one site; a lookup over 2 seconds means a dead first name server; no nameserver line at all),
and on Linux that the clock is kept right (chrony's offset: a warning from 1 second, bad from 60;
otherwise timedatectl's NTP and synchronized) and that the machine's own name is known, without
which sudo waits seconds on every run.

## Drives

`bsweep drives` reads the health of every physical disk and says Healthy, Worn or Failing, with
the reasons in plain words: sectors it can't read right now (pending), data it couldn't recover
(uncorrectable), worn-out sectors swapped for spares (reallocated), an NVMe drive's share of its
rated life used, its media errors and critical warnings, heat, and how long it has been on. It
only reads: nothing is written to a disk, no self test starts, and a sleeping disk isn't woken
(`smartctl -n standby`). Free, like every look.

    sudo bsweep drives
    sudo bsweep drives --json     {"drives": [...], "note": "..."}; exit 0 healthy, 1 worn, 2 failing

| System | Where it reads |
|---|---|
| Linux | the disks in /sys/block; `smartctl -j -a` when installed, `nvme smart-log` for NVMe without it. Needs sudo |
| macOS | `smartctl` when installed; otherwise `diskutil info`, which only says Verified or Failing |
| Windows | `smartctl` when installed; otherwise `Get-PhysicalDisk` and `Get-StorageReliabilityCounter` (wear, temperature, errors need Run as administrator) |
| BSD, Solaris | `smartctl` |

Without smartctl it says how to install it for this system (`sudo apt-get install smartmontools`,
`brew install smartmontools`, `winget install smartmontools.smartmontools`, `pkg install
smartmontools`...). A virtual disk (a cloud server's, a VM's) is named as one: the machine under it
looks after the real drives, and SMART can't reach them. A failing drive is a problem in Health and
makes `bsweep check` critical (exit 2, a `CRITICAL drive` line, `drives` in its JSON, and the
webhook); a worn one is a warning. Drives that can't be read change nothing. In the app, Health
shows them and `:` drives runs the command.

## Backups in Health

Health names each backup tool it finds and says when it last worked: restic, borg and borgmatic,
rsnapshot, duplicity (and duply, Deja Dup), Timeshift, Snapper, Proxmox vzdump, Time Machine,
Windows Server Backup (wbadmin) and File History, and any timer or cron job named like a backup.
It reads only what needs no repository password: the systemd timer and service (`systemctl show`,
`journalctl -u`), cron's log, and each tool's own files (restic's cache and a local repository's
snapshots folder, borg's security folder, duplicity's manifests, rsnapshot's log and snapshot
folders, Timeshift's snapshot names, Snapper's info.xml, Proxmox's task list, `tmutil latestbackup`,
the Windows Backup event log).

- The last run failed after the last good one: a problem, with the command that says why.
- The last good run is over 8 days old: a problem; over 2 days: a warning ("fine if weekly").
- A backup timer that is switched off, or Time Machine with automatic backups off: a warning.
- Set up but no finished run found, or cron started it but nothing says whether it worked: a warning.
- Every backup on the system disk (snapshots included): a warning, since one disk failure loses both.
- Nothing found at all: a problem, unless backups run elsewhere.

Debian's dpkg-db-backup is not a backup and is never counted.

## Each finding, explained

Every Health finding (`health --json`, and `summary --json`'s `findings`) has an `id` that never
changes (`updates.security-waiting`, `services.failed`, `backups.stale`, `system.restart-needed`,
...), `about` (what it means, for someone who isn't a system administrator), `risk` (what can
happen if it is left; empty when all is well), `steps` (what a person can do), and, when ByteSweep
can fix it itself, `action`: a label and the bsweep words to run, preview first, then `--yes`
(`updates install --security`, `services restart NAME`, `reboot`). SSH, firewall and system
settings stay advice.

## Server maintenance

    bsweep maintain                                    the plan, the window, the last run
    sudo bsweep maintain plan --every weekly --day sun --at 03:00 \
        --steps updates-security,logs,clean-safe,restart-services --older 7d --yes
    sudo bsweep maintain window --days sat,sun --from 02:00 --to 05:00 --pause-alerts --yes
    sudo bsweep maintain run --dry-run                 what a run would do now
    sudo bsweep maintain run --yes                     run the plan now, whatever the window says
    bsweep maintain reports --limit 10                 what each run did, newest first (kept 90 days)
    sudo bsweep maintain plan off --yes
    sudo bsweep maintain window off --yes

A plan's steps always run in this order: `backup` (every backup ByteSweep set up, below),
`updates-security`, `updates-all`, `logs` (older than
`--older`), `clean-safe` (what `clean --safe` cleans), `restart-services` (the services updates left
running old files, as `updates` names them; SSH, the network and logins are never restarted), and
`reboot-if-needed` (only when the system says updates need it: in 2 minutes, with `bsweep reboot
cancel` to stop it). The plan runs from the timer `bytesweep-maintain` (systemd, launchd, Task
Scheduler or cron). Setting a plan, a window or switching one off needs root.

With a window on, every unattended change waits for it: the plan, log schedules (`schedule logs`)
and cleaning by itself (`auto`). What came due outside it runs when it opens (the
`bytesweep-window` timer). A window that ends before it starts (22:00 to 04:00) runs past midnight.
With `--pause-alerts`, the alerts timer sends nothing inside the window; what is still true after it
is sent then. `maintain run` is a person asking, so it runs at once.

    bsweep services                     failed ones first, with their last 5 log lines
    bsweep services --failed
    sudo bsweep services restart nginx --yes

Linux: systemd (or OpenRC on Alpine); macOS: launchd jobs that stopped with an error; Windows:
automatic services that stopped. A restart that starts and fails again says so (exit 3).

    bsweep reboot                       is a restart needed, why, how long it has run, one set?
    sudo bsweep reboot --yes            in 2 minutes
    sudo bsweep reboot --at 03:00 --yes
    sudo bsweep reboot --now --yes
    sudo bsweep reboot cancel --yes

    sudo bsweep backups                 every backup Health finds, where, when it last worked

`stats --history` shows what `monitor on` records every 5 minutes, now with each disk's space, for
30 days: `--since 24h|7d|30d` and `--points N` (300) average it down; disks keep the last value.

## Backups ByteSweep sets up

    bsweep backup                                       each backup, how it last went, when next
    sudo bsweep backup install-restic --yes             restic from the system's own packages
    sudo bsweep backup add --folders /etc,/srv --to /mnt/disk2/backup --yes
    sudo bsweep backup add --folders /srv --to sftp:backup@203.0.113.5:/backups/web1 \
        --keep 14,8,12 --every daily --at 01:30 --yes
    sudo -E bsweep backup add --folders /var/www --to s3:s3.amazonaws.com/bucket/web1 --with-maintenance --yes
    sudo bsweep backup run b1 --yes                     now; without an id, every backup
    sudo bsweep backup list b1                          its copies, newest first
    sudo bsweep backup restore b1 latest --to /root/restored --yes
    sudo bsweep backup restore b1 4f2a9c1e --path /srv/site/index.php --to /root/one --yes
    sudo bsweep backup check b1                         restic check: is the repository whole?
    sudo bsweep backup remove b1 --yes                  stops it; the copies and their password stay

restic does the work: encrypted, only what changed is copied, to a folder on another disk,
SFTP, S3, Backblaze B2 or a restic REST server. ByteSweep never writes a backup format of its own.
Each backup gets a password made for it, shown once when it is set up: keep it somewhere safe, off
the server, because without it the backup can't be read. It is kept root-only for the timer, in
`/etc/bytesweep/backup/ID/password`. S3 and B2 keys come from the environment (`sudo -E`), a
`--key-file` of `KEY=value` lines or `--key-stdin`, are kept root-only and never printed. A target
on the same physical disk as a folder it backs up (partitions, LVM and disk images are followed to
the disk under them), or an SFTP target on this machine, is refused: one broken disk would take both.
`--same-disk-ok` allows it for a first copy. A folder target must be new or empty.

After each run old copies are thinned with `restic forget --prune` and the keep rule
(`--keep DAILY,WEEKLY,MONTHLY`, 7,4,6 by default). A backup runs on its own timer
`bytesweep-backup-ID` (daily at 02:00 unless `--every`/`--day`/`--at` say), which doesn't wait for
the maintenance window, or with `--with-maintenance` as the maintenance plan's first step `backup`,
which does. Each run's result is kept where `bsweep backups`, Health and `alerts add backups` see it;
Health offers "Run backup ID now" when one failed or is late, and "Set up a backup" when there is
none and another disk is mounted.

`restore` never writes over the originals: files land under an empty or new folder, each with its
path below it (`/srv/site` in `/root/restored/srv/site`). `--in-place` puts them back where they
were, over today's files, and needs `--i-understand` too. `remove --forget-data` deletes the copies
as well (a folder repository is deleted only when it is one).

If restic is missing, `bsweep backup` says how to get it here: `apt-get install restic` (Debian,
Ubuntu), `dnf install restic` (Fedora; RHEL, Alma, Rocky and CentOS after `dnf install
epel-release`), `apk add restic`, `pacman -S restic`, `zypper install restic`, `pkg install restic`,
`brew install restic` (without sudo), `winget install restic.restic`.

## macOS and Windows in Health

Health reads each system's own protections, without administrator rights where it can, and says
where to change each one. It changes nothing.

| | macOS | Windows |
|---|---|---|
| Firewall | `socketfilterfw --getglobalstate`: off is a warning | `Get-NetFirewallProfile`, per network: off for all is a problem, for some a warning; another firewall Security Center knows counts |
| Disk encryption | `fdesetup status`: FileVault off is a warning | BitLocker on the system drive (`Win32_EncryptableVolume`, or the shell's BitLocker state without admin): off, paused or waiting for activation is a warning |
| Protection | `csrutil status`: SIP off is a problem; `spctl --status`: Gatekeeper off is a warning | `Get-MpComputerStatus` and Security Center's antivirus list: none on is a problem; real-time protection off or definitions over 7 days old a warning |
| Updates | macOS's own settings (`defaults read /Library/Preferences/com.apple.SoftwareUpdate`): security responses and system files not installed by themselves is a warning; what its last check recommended, and a last check over 14 days old | what Windows Update found at its own last check (the agent, offline: no new search, so it stays quick; "not checked" if it doesn't answer in time); security ones are a problem; a restart waiting is a warning |
| Services | launchd jobs not running whose last exit was an error, Apple's own and apps left out | automatic services that stopped with an error; delayed and trigger-started ones, and updaters that stop by design, left out |

For a fresh answer from Apple or Microsoft, `bsweep updates` asks them directly.

## Apps

`bsweep apps` lists what is installed, largest first, from the package managers and app folders
this system has: dpkg, rpm, pacman and apk packages, Flatpaks and Snaps on Linux; Homebrew
formulae and casks and the app bundles in /Applications and ~/Applications on macOS; the
uninstall entries Settings > Apps shows on Windows; pkg on FreeBSD. Looking is free.

    bsweep apps
    bsweep apps --json
    bsweep apps remove cowsay --dry-run
    sudo bsweep apps remove cowsay
    sudo bsweep apps remove snap:lxd --yes      a name two sources share needs its ID
    bsweep apps leftovers
    sudo bsweep apps leftovers clean rc:cowsay dir:3fa2c1d0
    sudo bsweep apps leftovers clean --all --dry-run

`remove` goes through the package manager's own command, shown first, after that manager's own
dry run says what else would go: `apt-get -s remove`, `dnf remove --assumeno` (or yum, or
`zypper remove --dry-run`), `pacman -R --print`, `apk del -s`, `pkg delete -n`. Snap, Flatpak,
Homebrew and winget have no dry run and remove only the one named; brew refuses by itself when
another formula needs it, and runs as whoever owns the Homebrew folders, never as root. A Mac app
bundle goes to Undo. Some things always stay, by themselves or when they would go along with
another: packages dpkg marks Essential or of required or important priority, the running kernel,
systemd, sshd, libc, sudo, bash, coreutils, boot loaders, every package manager, base and snapd
snaps, apps that came with macOS, Windows runtimes other programs need, and ByteSweep itself.
Removing needs `sudo`; `--dry-run` doesn't where the manager allows it.

`leftovers` lists only what clearly belongs to a removed app:

- settings files dpkg kept for a removed package (state `rc`), purged with `dpkg --purge NAME`,
  which Undo can't hold;
- a Flatpak's `~/.var/app/ID` or a snap's `~/snap/NAME` when that app is no longer installed;
- a folder in `~/.config`, `~/.local/share`, `~/.local/state` or `~/.cache` (`~/Library/...` on
  macOS, `AppData` on Windows) named exactly like an app the system's own records say was
  removed (dpkg.log, apt's history.log, pacman.log, dnf.rpm.log and `snap changes` on Linux;
  InstallHistory.plist on macOS; Windows Installer's removal events), with nothing installed,
  running or on the PATH by that name, and nothing written inside since the removal (30 days
  when the record has no date). Folders shared by the desktop and toolkits never count.

Folders go to Undo for 7 days; `--now` removes them at once, and a Mac app bundle too
(`apps remove NAME --now`). IDs are `rc:NAME` and `dir:` with eight letters made from the path;
`clean` takes either, or the path itself.

## History

`bsweep log` as a screen: every change, newest first, with when, who, what it did, what it freed,
and whether it is still in Undo. Enter on a row that is goes to it on the Undo screen, to put it
back. Failed changes are marked. `o` steps through 30, 7, 1, 90 and 365 days; `log --since` in
the `:` list opens it at any age. Without `sudo` it also reads what you changed in your own
settings folder.

## Servers

The fleet view: every saved host, and for each server what `bsweep fleet status` asks (its
fullest disk, updates waiting and how many are security fixes, problems and warnings, its
maintenance plan and last run, whether its backups are recent, what is safe to clean), over SSH
with your keys, eight servers at a time, a minute each at most, so one that can't be reached
never holds up the rest. `r` asks again. `s` sorts by name, fullest disk, updates or problems;
servers that didn't answer go last. `T` shows only the hosts with one tag, then the next tag, then
all; `#` sets the chosen host's tags (`host tag NAME prod,db`).

`c` `l` `u` `U` `M` `v` run `fleet run clean-safe`, `logs-clear`, `updates-security`,
`updates-all`, `maintain-run` or `services-restart NAME` on the ticked servers (or the chosen
one): each server's own preview comes first, with what it would do; Enter runs it on those that
can, one at a time, stopping at the first failure; `F` keeps going past one. Each server needs `sudo` without a password for bsweep. A plan
whose steps restart the server says so before it runs. What ran is kept 90 days
(`fleet history`).

`+` and `e` open the host form (`host add`, `host edit`: type, address, port, SSH options), `t`
runs `host test`, and `x` forgets the ticked hosts after one question, unless a folder pair uses
one. Enter hands the terminal to `connect`. No password is ever kept: a host needs an SSH key
that logs in without one.

### Fleet from the command line

    bsweep host tag web1 prod,db        bsweep host untag web1 db   (no tag: all off)
    bsweep fleet status [--hosts a,b | --tag T] [--sort name|disk|updates|problems] [--parallel 8] [--timeout 60s] [--json]
    bsweep fleet run ACTION [NAME] --hosts a,b | --tag T | --all [--dry-run | --yes] [--keep-going] [--parallel 1] [--timeout 10m] [--json]
    bsweep fleet history [--limit 30] [--json]

Actions: `updates-security`, `updates-all`, `clean-safe`, `logs-clear` (older than 7 days),
`maintain-run`, `services-restart NAME`. Nothing else can be run this way: each server runs
`sudo -n bsweep` with those fixed words and `--json`, and nothing typed reaches its shell except
a service name that is checked and quoted. Without `--yes` every server shows its own preview
(nothing changes; in a terminal it then asks once). `fleet status` exits 2 when a server can't
be reached or has a problem, 1 for warnings; `fleet run --yes` exits 3 when any server failed
or wasn't run. The record is `fleet-history.jsonl` beside `bsweep.yml`.

## Settings

One screen for every switch, with how it stands: the daily record and alarm (`timer`), the monitor, cleaning by itself (`auto`, with its limit),
the log schedules, the line at login (`motd`, Linux), the settings file (`config check`), the
hosts and folders file (`init` when it is missing), the version (`update`) and tab completion.
Enter runs the same command the `:` list would, so it asks the same question first.

## Your files

Four commands for a person's own files, with the desktop apps' rules. Each shows its plan first
and changing files never needs `sudo` for your own folders. The
system's folders, databases' folders, the Undo store, the config's keep list, the top of a disk
and a home folder itself are refused. `--json` works on all four (nothing changes without
`--yes`). In the app they are the "Your files" group of the `:` list, each with its dry run first.

    bsweep organize ~/Downloads --by kind --dry-run     Pictures, Documents, Videos, Music, Archives, Installers, Code, Other
    bsweep organize ~/Pictures/inbox --by date          2026/October
    bsweep organize /srv/uploads --by kind-date --yes   Pictures/2026/October
    bsweep organize undo [DIR] [--dry-run]

`organize` moves only the files loose in the folder: folders already in it (and so everything
already filed) are never opened or moved. Hidden files, links, unfinished downloads, files
another program has open (Linux) and files changed in the last 10 minutes stay where they are,
each with the reason. Nothing is deleted or replaced: a name that is taken gets a number,
"photo (2).jpg". The date is when the file last changed. A project folder (.git, package.json,
go.mod...) is refused whole. A journal is written before the first file moves; `organize undo`
puts every file back, removes the folders it made once they are empty, and works after a run
that stopped half way. Journals are kept in `~/.config/bytesweep/journal` (in
`/var/lib/bytesweep/journal` with `sudo`).

    bsweep tidy                                         your Downloads folder (XDG_DOWNLOAD_DIR on Linux)
    bsweep tidy /srv/uploads --dry-run
    bsweep tidy --rule installers,copies --older 60d --yes
    bsweep tidy --rule never-opened --older 180d

| Rule | Takes |
|---|---|
| installers | .dmg .pkg .exe .msi .msix .appx .deb .rpm .AppImage .snap .apk... older than 30 days (`--older`), confirmed by their first bytes, never an encrypted disk image |
| archives | a .zip whose every file is beside it at the same length (in a folder of its name, or next to it); a .tar.gz, .7z, .rar... when a non-empty folder of its name was made after it |
| copies | "name (1).ext" or "name-1.ext" identical by SHA-256 to the original, which stays |
| unfinished | .crdownload .part .partial .download not written to for a day |
| never-opened | files not opened since they arrived, older than 90 days (`--older`). Only when named, and only on Linux disks not mounted `noatime`; elsewhere it says it can't tell |

A plain `tidy` uses the first four. Anything that arrived, changed or was opened in the last 3
days is left alone, and folders in it are never touched. Every file is checked again just
before it goes, and goes to Undo for 7 days: `bsweep undo` lists and restores it (`--now`
removes it at once instead, with no Undo). Without `sudo`
your files go to `~/.bytesweep-undo` when the top of the disk can't be written; it is the same
Undo, and its 7 days end the same way. Reading files to compare them never marks them opened.

    bsweep rename ~/Pictures/trip --name Lisbon --number 1 --dry-run   Lisbon 001.jpg, Lisbon 002.jpg...
    bsweep rename ~/Pictures/trip --date --yes                         2026-10-05 IMG_4127.jpg
    bsweep rename ./scans --replace scan_=invoice- --case lower --suffix -2026
    bsweep rename undo [--dry-run]

`rename` takes files, or a folder for the files directly in it. Steps run in a fixed order:
`--name`, `--replace FIND=WITH` (any number of times, capitals aside), `--case lower|upper|title`,
`--date` (when a JPEG says it was taken, else when the file last changed; in front), `--prefix`,
`--suffix`, `--number START` (after, three digits or more). Files are numbered in name order,
2 before 10. The ending never changes. The list of old and new names always shows first, and
any problem on any row stops the whole rename: two files getting one name, a name already
there, a name the system can't have (a slash; on Windows also `\ : * ? " < > |`, CON, NUL and
the like; a leading dot, which would hide the file). Names can swap. `rename undo` puts back the
last rename, then the one before.

    bsweep convert ~/Pictures/screens --to jpeg --dry-run
    bsweep convert logo.png --to jpeg
    bsweep convert photo.jpg banner.gif --to png --yes

`convert` writes new files beside the originals and never changes an original. It reads JPEG,
PNG and GIF; HEIC, WebP, AVIF, TIFF, BMP, SVG and RAW are listed as left alone, by name, since
this program carries no codecs for them. Photos are turned upright as their camera says;
see-through parts become white in a JPEG; a moving GIF gives its first frame. Each new file is
written under a hidden name, read back to check it opens, then given its name without replacing
anything. Pictures over 150 megapixels are left alone.

## AI assistants (MCP)

`bsweep mcp` lets Claude Desktop, Claude Code, Cursor or VS Code look at this machine and plan
cleaning, over the Model Context Protocol. Changes are a plan the person sees first, applied only
when the server was started with `--allow-changes`, and written to `bsweep log` as user `mcp`.
`bsweep mcp config` prints the line to add it, e.g. `claude mcp add --scope user bsweep -- /usr/local/bin/bsweep mcp`.
In the app: Settings, "Use with an AI assistant", or `:mcp config`. Everything else: docs/mcp.md.

## Rescue USB

For a computer whose disk is so full it won't start. Details: `rescue-usb/README.md`.

    bsweep rescue-usb [--arch x86_64|aarch64] [--out FILE] [--dry-run] [--json [--yes]]
    sudo bsweep rescue-usb write --image FILE --device DEVICE [--dry-run | --yes] [--confirm DEVICE] [--json]
    sudo bsweep rescue-boot [--list] [--plain] [--json]           on the USB (Linux only)
    sudo bsweep rescue --root /mnt/target [--dry-run] [--hard] [--json [--yes]]
    sudo bsweep clean  --root /mnt/target ...    bsweep why --root /mnt/target    bsweep top --root /mnt/target /var

- `rescue-usb` downloads `bsweep-rescue-ARCH.iso` from the release folder (next to
  `bsweep-linux-x86_64`) and keeps it only if its SHA-256 is the one in
  `bsweep-SHA256SUMS.txt`, whose signature is checked with the key built into bsweep
  (the same check `bsweep update` does). Free.
- `rescue-usb write` erases the device, writes the image and reads it back to compare.
  Never the disk this computer runs from. A built-in disk, a virtual disk (loop) or a disk
  with a mounted part needs the device name typed, or `--confirm DEVICE`; its parts are
  unmounted first. A plain file as `--device` gets the image copied. Free; root for devices.
- `--root DIR` points rescue, clean, why and top at another computer's system mounted at
  DIR (never `/`). The rules are then `rules.ScanRoot`'s: files only, read the way that
  system reads them (its links stay inside it), and nothing goes to Undo.
- In the app: `: rescue-usb`, `: rescue-usb write`, `: rescue-boot --list`. On the USB,
  rescue-boot opens the app on the chosen disk, with Rescue's plan on screen.
