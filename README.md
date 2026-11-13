<p align="center">
  <b>English</b> ·
  <a href="README.de.md">Deutsch</a> ·
  <a href="README.es.md">Español</a> ·
  <a href="README.fr.md">Français</a> ·
  <a href="README.it.md">Italiano</a> ·
  <a href="README.nl.md">Nederlands</a> ·
  <a href="README.pl.md">Polski</a> ·
  <a href="README.pt-BR.md">Português (Brasil)</a> ·
  <a href="README.ru.md">Русский</a> ·
  <a href="README.tr.md">Türkçe</a> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.ko.md">한국어</a> ·
  <a href="README.zh-Hans.md">简体中文</a> ·
  <a href="README.zh-Hant.md">繁體中文</a>
</p>

<h1 align="center">ByteSweep CLI: Disk Space Analyzer and Cleaner for Linux, Mac and Windows</h1>

<p align="center">
  <b>Why is my disk full? Find out, and free the space safely, in any terminal.</b><br>
  A free, open-source disk space analyzer and cleaner for Linux servers, Mac, Windows and the BSDs.
</p>

<p align="center">
  <a href="https://bytesweep.app/cli"><img alt="Release" src="https://img.shields.io/badge/download-bytesweep.app%2Fcli-2ea44f?style=flat-square"></a>
  <a href="https://github.com/bytesweepcleaner/bytesweep-cli/blob/main/LICENSE"><img alt="Licence: GPL-3.0" src="https://img.shields.io/badge/licence-GPL--3.0-blue?style=flat-square"></a>
  <a href="https://github.com/bytesweepcleaner/bytesweep-cli/actions/workflows/test.yml"><img alt="Tests" src="https://img.shields.io/github/actions/workflow/status/bytesweepcleaner/bytesweep-cli/test.yml?branch=main&label=tests&style=flat-square"></a>
  <a href="https://github.com/bytesweepcleaner/bytesweep-cli/blob/main/go.mod"><img alt="Go 1.22+" src="https://img.shields.io/badge/go-1.22%2B-00ADD8?style=flat-square"></a>
  <a href="docs/platforms.md"><img alt="Linux, macOS, Windows, BSD" src="https://img.shields.io/badge/runs%20on-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20BSD-555?style=flat-square"></a>
  <a href="https://github.com/bytesweepcleaner/bytesweep/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/bytesweepcleaner/bytesweep?style=flat-square"></a>
</p>

<p align="center">
  <img src="docs/images/bsweep-overview.png" width="900" alt="ByteSweep CLI in a terminal: a Linux server's root disk at 100%, with why it is full, what can be cleaned with no risk, and the Rescue key">
</p>

ByteSweep CLI (`bsweep`) tells you **why a disk is full** and frees the space **without breaking anything**.
It reads `df`, `du`, Docker, the systemd journal, package caches, old kernels, deleted files that are
still open, inodes and snapshots, and explains the answer in plain words. Every cleanup shows the exact
command first, the risky ones wait for a look, and files you remove go to Undo for 7 days.

It is one static file: no runtime, no agent, nothing left running. **Free and open source (GPL-3.0):
every command, on every machine, with no licence, key or trial.**

## Features

- **Why it's full, in one answer.** `bsweep why` names the folders, caches and logs that take the space, and the gap `du` can't see.
- **"No space left on device" with free bytes.** Inodes per disk, and the folders with the most files.
- **`df` and `du` disagree.** The Held screen lists deleted files still kept open, and the service that holds each one.
- **Docker disk usage.** Build cache, unused images, stopped containers and container logs; volumes are never pruned.
- **Logs.** Vacuum the systemd journal, clear rotated logs, empty huge live logs in place; schedule it daily, weekly or monthly.
- **A full disk right now.** `bsweep rescue` frees just enough, safest first, and writes nothing to the full disk.
- **Safe by design.** Exact commands shown first, `--dry-run` everywhere, Undo for 7 days, never your databases or the running kernel.
- **Duplicates, big files, compress and archive.** Find copies by content, gzip old logs, move old projects to another disk and bring them back.
- **Health, updates, ports and startup.** Failed services, out-of-memory kills, dying disks, expired certificates, backups that stopped, what listens on each port.
- **Many servers.** `bsweep fleet` over SSH with nothing installed, `bsweep manage` for every server on one screen.
- **AI assistants.** `bsweep mcp` is a Model Context Protocol server for Claude, Cursor, VS Code and any MCP client.
- **Scripts and monitoring.** `--json` on almost every command, exit codes for `bsweep check`, webhooks.

## Install

Linux, macOS and the BSDs:

```sh
curl -fsSL https://bytesweep.app/install-cli.sh | sudo sh
```

Windows (PowerShell as administrator):

```powershell
irm https://bytesweep.app/install-cli.ps1 | iex
```

Both check the signed checksums before anything is installed. With Go 1.22 or newer you can also build it yourself:

```sh
go install github.com/bytesweepcleaner/bytesweep-cli/cmd/bsweep@latest
```

`sudo bsweep update` gets the next release. Every system and processor: [docs/platforms.md](docs/platforms.md).

## Supported systems

One static `bsweep` file for each system and processor: 23 builds in all. The install line picks the right one.

| System | Processors | Versions |
|---|---|---|
| **Linux** | x86_64, ARM64, ARMv7, i386, RISC-V 64, ppc64le, s390x, LoongArch64 | Any distribution: Ubuntu, Debian, Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux, openSUSE, Arch, Alpine and more |
| **Mac** | Apple silicon (ARM64), Intel (x86_64) | macOS 11 Big Sur and later |
| **Windows** | x64, ARM64, 32-bit (i386) | Windows 10 and 11 |
| **FreeBSD** | x86_64, ARM64 |  |
| **OpenBSD** | x86_64, ARM64 |  |
| **NetBSD** | x86_64, ARM64 |  |
| **DragonFly BSD** | x86_64 |  |
| **Solaris** | x86_64 |  |
| **illumos** | x86_64 |  |
| **AIX** | ppc64 |  |
| **Android** (Termux) | ARM64 | Linux ARM64 build in Termux; looking only, because Android gives no root |

Works in any terminal: Terminal, iTerm2, Windows Terminal, PowerShell, GNOME Terminal, Konsole, xterm, the Linux console, tmux, screen, PuTTY and over SSH. What differs on each system: [docs/platforms.md](docs/platforms.md).

## Quick start

```sh
sudo bsweep                        # the full-screen app
bsweep why                         # one answer: why this disk is full
sudo bsweep rescue                 # disk at 100%: free just enough, safest first
bsweep clean --list                # everything that can go, by group
sudo bsweep clean --safe --dry-run # what a safe clean would do, without doing it
bsweep dupes /srv --dry-run        # duplicate files, and which copy would stay
bsweep check                       # exit code for monitoring and cron
```

## ByteSweep for your phone and computer

<p align="center">
  <a href="https://bytesweep.app/?ref=github"><img src="docs/images/bytesweep-apps-en.png" width="900" alt="ByteSweep apps for iPhone, Android, Mac, Windows and Linux"></a>
</p>

<p align="center">
  <a href="https://apps.apple.com/us/app/bytesweep-storage-cleaner/id6811826959"><img alt="App Store: iPhone & iPad" src="https://img.shields.io/badge/App_Store-iPhone_%26_iPad-0D96F6?style=for-the-badge&logo=apple&logoColor=white" height="44"></a>
  <a href="https://play.google.com/store/apps/details?id=com.bytesweep.app"><img alt="Google Play: Android" src="https://img.shields.io/badge/Google_Play-Android-34A853?style=for-the-badge&logo=googleplay&logoColor=white" height="44"></a>
  <a href="https://apps.microsoft.com/detail/9N7WMJS8QCQX"><img alt="Microsoft Store: Windows" src="https://img.shields.io/badge/Microsoft_Store-Windows-0078D4?style=for-the-badge" height="44"></a>
  <a href="https://bytesweep.app/mac.html?ref=github"><img alt="Download for Mac" src="https://img.shields.io/badge/Download-Mac-111111?style=for-the-badge&logo=apple&logoColor=white" height="44"></a>
  <a href="https://bytesweep.app/linux.html?ref=github"><img alt="Download for Linux" src="https://img.shields.io/badge/Download-Linux-E95420?style=for-the-badge&logo=linux&logoColor=white" height="44"></a>
</p>

The CLI is free and stays free. For the phone in your pocket and the computer on your desk there are ByteSweep apps, with the same rule: you see everything before it goes.

<table>
  <tr>
    <td><b>iPhone &amp; iPad</b></td>
    <td>Find similar photos and duplicates, shrink big videos and swipe through old months. Free for your first 1 GB and 30 items, then pay once.</td>
    <td><a href="https://apps.apple.com/us/app/bytesweep-storage-cleaner/id6811826959"><img alt="App Store: iPhone & iPad" src="https://img.shields.io/badge/App_Store-iPhone_%26_iPad-0D96F6?style=for-the-badge&logo=apple&logoColor=white" height="36"></a></td>
  </tr>
  <tr>
    <td><b>Android</b></td>
    <td>Find similar photos, duplicates, big videos and unused apps. Free for your first 1 GB and 30 items, then pay once, no subscription.</td>
    <td><a href="https://play.google.com/store/apps/details?id=com.bytesweep.app"><img alt="Google Play: Android" src="https://img.shields.io/badge/Google_Play-Android-34A853?style=for-the-badge&logo=googleplay&logoColor=white" height="36"></a></td>
  </tr>
  <tr>
    <td><b>Mac</b></td>
    <td>Finds what filled your Mac, from System Data to Docker and Xcode, with a 7-day Undo for what can go back. Free to try for 3 days. Also on the Mac App Store.</td>
    <td><a href="https://bytesweep.app/mac.html?ref=github"><img alt="Download for Mac" src="https://img.shields.io/badge/Download-Mac-111111?style=for-the-badge&logo=apple&logoColor=white" height="36"></a><br><a href="https://apps.apple.com/us/app/bytesweep-storage-transfer/id6822710125?mt=12"><img alt="Mac App Store" src="https://img.shields.io/badge/Mac_App_Store-Mac-0D96F6?style=for-the-badge&logo=appstore&logoColor=white" height="36"></a></td>
  </tr>
  <tr>
    <td><b>Windows</b></td>
    <td>Clears Windows Update leftovers, temp files and browser and game caches, with a 7-day Undo for what can go back. Free to try for 3 days.</td>
    <td><a href="https://apps.microsoft.com/detail/9N7WMJS8QCQX"><img alt="Microsoft Store: Windows" src="https://img.shields.io/badge/Microsoft_Store-Windows-0078D4?style=for-the-badge" height="36"></a></td>
  </tr>
  <tr>
    <td><b>Linux</b></td>
    <td>Clears apt, dnf and pacman caches, old snaps, unused Flatpak runtimes and the journal, and finds duplicates and big files. Free to try for 3 days.</td>
    <td><a href="https://bytesweep.app/linux.html?ref=github"><img alt="Download for Linux" src="https://img.shields.io/badge/Download-Linux-E95420?style=for-the-badge&logo=linux&logoColor=white" height="36"></a></td>
  </tr>
</table>

## Every problem it answers

| Pain on a real server | What ByteSweep does |
|---|---|
| `df` says full, `du` disagrees | Held tab: deleted files still open, who holds them. Overview names any gap a scan can't see |
| "No space left" with free bytes | Inodes per disk, Explore sorts by file count (`i`) |
| Docker ate the disk | Build cache, untagged and unused images, stopped containers, container logs `docker system df` doesn't show; every VM (Colima, Lima, Podman, Multipass, Vagrant, minikube, Android emulators...) by name, with space it can give back |
| A blind prune deleted a database | Volumes are never pruned. Databases and /var/lib/docker can't be cleaned by hand either |
| Journal, rotated logs, huge live logs | Vacuum through journalctl; live logs emptied in place so services keep writing |
| /boot full, upgrades fail | Old kernels, never the running one |
| Package and language caches, old snaps, crash dumps, old /tmp | Each through its own tool; the exact command is shown first |
| The plan was upgraded, the disk wasn't | Finds disk space outside any partition |
| ext4's hidden 5% | Names reserved space and the tune2fs line |
| It fills again next month | Prevent tab: journal cap, Docker log limit, daily record |
| "What changed overnight?" | What grew, and when the disk will be full at this pace |
| The scan slows production | Runs at low CPU and idle disk priority; stays on one disk |
| Disk at 100% and everything is failing | `bsweep rescue` or `R`: frees just enough, safest first, then names the services that stopped. Writes nothing to the full disk |
| Podman or Kubernetes nodes | Same cleanup through podman and crictl; volumes stay untouched |
| Snapshots holding space | `bsweep snapshots`: Time Machine, restore points, shadow copies, Timeshift, Snapper, ZFS, Btrfs and LVM, with sizes where the tool can say. Removes only what you pick and keeps the newest of each |
| Files hidden under a mount | Looks beneath every mount through a read-only bind and shows how to reach them |
| Old deploys and web app leftovers | Old releases (keeps live + 3), WordPress cache, Laravel logs, PHP sessions |
| Logs need clearing regularly | `bsweep logs clear`, or `bsweep schedule logs` daily, weekly or monthly |
| A log nothing rotates | Prevent writes a logrotate rule, tested before it stays |
| Old projects filling a busy disk | `bsweep archive /srv/old --to /mnt/backup`: to another disk, every file checked by checksum, then freed; `where` works with it unplugged, `bring-back` puts it back |
| Old logs and dumps taking space | `bsweep compress /var/log --older 30d`: gzip where it saves, read back before the original goes to Undo; live logs stay |
| The same files, three times over | `bsweep dupes`: copies by content, hard links and clones counted once; keep one, the rest to Undo |
| Downloads full of old installers and "(1)" copies | `bsweep tidy`: the desktop's rules, each file to Undo; `organize`, `rename` and `convert` for the rest, each shown first and undoable |
| "What is on port 3000?" | `bsweep ports`: program, project or container, open to the network or not; stop a dev project in one go |
| Which package is huge, and what removed apps left | `bsweep apps`: every package and app, largest first; remove through apt, dnf, pacman, snap, flatpak or brew after their own dry run; never what the system needs |
| Chat apps quietly filling the disk | Chats and Mail group: Slack, Teams, Discord, Element and Thunderbird caches for review; Telegram files and Zoom recordings only one by one, to Undo |
| Which apps can use the camera, microphone or screen? | `bsweep permissions`: allowed and refused, last used and in use now where the system records it (macOS TCC, Windows privacy settings, Flatpak, Snap, open devices); only reads, says where to switch each off |
| Command history and other traces | Privacy traces group: shell and REPL history, recent files, previews, editor backups; always for review, each to Undo |
| Updates waiting, and is a restart needed? | `bsweep updates`: security fixes first, through apt, dnf, zypper, pacman, apk, snap, flatpak, Homebrew, winget, macOS's Software Update or Windows Update; names who holds a busy package lock; never restarts by itself |
| A program that won't quit | `bsweep stop PID\|NAME`, or `s` on Live: asks it to close, 10 seconds to save; never sshd, PID 1 or your own shell, and a service gets its `systemctl` command instead |
| "Why did it wake up at 3 am?" | `bsweep sleep`: each sleep and what woke it (lid, USB, Bluetooth, network, a timer), what keeps it awake now, wakes planned; advice only, no power setting changed. A server that never sleeps says so |
| "What can people see?" | `bsweep sharesafe`: shared folders (guest? can they change files?), file and screen sharing, SSH, remote desktop, open ports, Docker's published ports, the firewall; a risk for each and where to switch it off. Only reads |
| What starts by itself, and what failed | `bsweep startup`: systemd, cron @reboot, launchd, Windows services; the system's own only with `--all`; switch off and back on exactly |
| Service died in the night | Health tab: out-of-memory kills, failed services, crash loops |
| A disk about to die | `bsweep drives`: every physical disk Healthy, Worn or Failing, and why in plain words; `check` and Health warn too. Only reads |
| "Do the backups even run?" | Health names the tool (restic, borg, rsnapshot, duplicity, Timeshift, Snapper, vzdump, Time Machine, Windows Backup) and when it last worked or failed. No repository password needed |
| Certificate expired by surprise | Reads nginx, Apache, Caddy and Let's Encrypt certs; flags broken renewal |
| Updates, SSH, firewall, backups | Health on macOS and Windows also reads the firewall, FileVault or BitLocker, SIP and Gatekeeper or the antivirus. Advice with exact commands. ByteSweep won't change SSH or firewalls: that's how people get locked out |
| Many servers | `bsweep fleet`: one table over SSH, nothing installed |
| Moving files without scp syntax | Save a host once, then `bsweep copy-to office ./site /srv/site` |
| A dropped transfer starts over | Resumes where it stopped and sends only what changed |
| A sync wipes the wrong folder | Shows changes first, keeps removed files 7 days, refuses to empty a folder |
| Reviewing a server from your laptop | `bsweep connect office` opens the full app on it |
| Too many servers to keep track of | `bsweep manage`: every server on one screen, with live Monitor and bulk actions |
| Part of a monitoring setup | `bsweep check` exit codes, webhook, `report --json`, `clean --safe --yes` |

Every command and exit code: [docs/cli.md](docs/cli.md). Cron, Ansible, CI and fleet examples: [docs/recipes.md](docs/recipes.md).

## How Clean and Undo work

- **Clean** in Explore moves the file to `<disk>/.bytesweep-undo` for 7 days. A move on the
  same disk frees nothing, so the space returns when Undo ends. The screen says this.
- **Remove now** returns the space at once, with no Undo: `F` in the app's question, `--now` on
  every command that would use Undo (rm, dupes, clean, apps, tidy, compress). That is the choice
  on a disk at 100%. `bsweep undo free --all` empties Undo itself.
- Rule cleanups go through journalctl, docker, apt and friends, and can't be undone. The
  confirm screen lists every command.

## Hosts, transfer and sync

Set a host up once in `bsweep.yml` (`bsweep init`, then `bsweep host add`), and use its short name after
that, from a server or from a Mac or Windows command line. See [docs/transfer.md](docs/transfer.md).

## AI assistants (MCP)

`bsweep mcp` lets Claude Desktop, Claude Code, Cursor, VS Code and other MCP clients look at a machine
and help clean it, with the same rules as the command line. See [docs/mcp.md](docs/mcp.md).

## FAQ

**How do I find out what is using disk space on Linux?**
Run `bsweep why` for a one-screen answer, or `sudo bsweep` and open Explore to walk the folders,
largest first. It also counts what a folder walk can't: deleted files still held open, Docker, snapshots and reserved space.

**Why does `df` say the disk is full when `du` adds up to less?**
Usually a program still holds a deleted file open, often a log. The Held screen lists each one and the
service that holds it, and empties a held log in place so the service keeps writing.

**How do I fix "No space left on device" when `df` shows free space?**
The disk is out of inodes: too many small files. ByteSweep shows inodes per disk, and Explore sorts by
file count (`i`) to find the folder that holds them.

**How do I free Docker disk space safely?**
`bsweep clean --list --group containers` lists build cache, unused images, stopped containers and
container logs. Volumes are never pruned, because a volume can be a database.

**My server's disk is at 100%. What now?**
`sudo bsweep rescue`, or `R` in the app. It frees just enough, safest first, writes nothing to the full
disk, then names the services that stopped.

**Is it safe to run on a production server?**
Every cleanup shows its exact command first, `--dry-run` previews anything, removed files wait in Undo
for 7 days, and scans run at low CPU and idle disk priority. It never removes databases, Docker volumes
or the running kernel, never picks a snapshot for you, and never changes SSH or firewall settings.

**Is it free? Does it send data anywhere?**
Free and open source under GPL-3.0, with no account, analytics or trial. It goes online only when you ask:
`bsweep update`, alerts to the places you add, and SSH for fleet, copy and sync.

## Privacy

No analytics and no account. Nothing about you or your files leaves the machine. bsweep goes
online only when you ask it to: `bsweep update` downloads from bytesweep.app (and checks the
signature first), alerts go only to the places you add, and fleet, copy and sync use your own SSH.

## Build and test

Needs Go 1.22 or newer: `go test ./...`, then `go build -o bsweep ./cmd/bsweep`.
`VERSION=1.0.1 ./build.sh` makes every release build. See [bytesweep-cli](https://github.com/bytesweepcleaner/bytesweep-cli) and
[SECURITY.md](SECURITY.md).

## Licence

GPL-3.0: free to use, change and share. A changed copy you give to others must stay open
under the same licence. See [LICENSE](https://github.com/bytesweepcleaner/bytesweep-cli/blob/main/LICENSE).

---

ByteSweep also comes as a desktop app for Mac, Windows and Linux: [bytesweep.app](https://bytesweep.app/?ref=github)
