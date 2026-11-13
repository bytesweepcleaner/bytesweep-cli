# Every system

One program, `bsweep`, for every terminal: Linux, macOS, Windows, the BSDs, Solaris, illumos and AIX.
It is one static file with no runtime, built for 23 system and processor pairs; `bsweep update`
and `bsweep connect` pick the right one.

| System | Install | Run as administrator |
|---|---|---|
| Linux, any distribution | `curl -fsSL https://bytesweep.app/install-cli.sh \| sudo sh` | `sudo bsweep` |
| macOS 11 and later, Apple silicon or Intel | same line | `sudo bsweep` |
| FreeBSD, OpenBSD, NetBSD, DragonFly, Solaris, illumos, AIX | same line (curl, wget or ftp) | `sudo bsweep` or `doas bsweep` |
| Windows 10 and 11, x64, ARM64, 32-bit | `irm https://bytesweep.app/install-cli.ps1 \| iex` | terminal opened with Run as administrator |
| Android, in Termux | the Linux arm64 file | looking only: Android gives no root |

## Terminals

The full-screen app draws in any terminal that understands ANSI: Terminal, iTerm2, Windows
Terminal, the Windows console, PowerShell, GNOME Terminal, Konsole, xterm, the Linux console,
tmux, screen, PuTTY and SSH from any of them. Mouse works where the terminal sends it.

- Not UTF-8, or `TERM` is vt100, vt220 or ansi: boxes and bars are drawn in ASCII. `BSWEEP_ASCII=1` forces it, `0` turns it off.
- `NO_COLOR` turns colour off.
- No terminal at all (a pipe, cron, `TERM=dumb`): `bsweep` prints the `why` summary instead of the app.
- Tab completion: `bsweep completion bash|zsh|fish|powershell`.

## What differs

| | Linux | macOS | Windows | BSD, Solaris, AIX |
|---|---|---|---|---|
| Disks | mountinfo | both halves of the startup disk shown as one | fixed and removable drives | getfsstat or df |
| Undo store | `<disk>/.bytesweep-undo` | `/System/Volumes/Data/.bytesweep-undo` for the startup disk | `C:\.bytesweep-undo`, hidden | `<disk>/.bytesweep-undo` |
| Settings | /etc/bytesweep | /Library/Application Support/ByteSweep CLI | %ProgramData%\ByteSweep CLI | /usr/local/etc/bytesweep (BSD) |
| Schedules, auto, monitor, timer | systemd timers; cron without systemd | launchd (/Library/LaunchDaemons) | Task Scheduler, folder ByteSweep | root's crontab |
| Cleaning rules | journal, packages, kernels, snaps, Docker, Podman, k8s, web apps, logs, crash dumps, tmp, language caches | app caches, Trash, Xcode DerivedData, Homebrew and language caches, logs, crash reports, tmp, Docker | Windows Update downloads, Recycle Bin, crash dumps, Temp, IIS logs, language caches, Docker | pkg cache (FreeBSD), logs, crash dumps, tmp, language caches, Docker |
| Held files, hidden under mounts, grow, motd, swap, journald, logrotate | yes | no | no | no |
| Health | everything | memory, certificates, backups (Time Machine, restic, borg, duplicity), drives, firewall, FileVault, SIP, Gatekeeper, Software Update, failing launchd jobs | memory, certificates, backups (Windows Backup, File History, restic), drives, firewall, antivirus, BitLocker, Windows Update, stopped services | memory, certificates, drives |
| Updates | apt, dnf, yum, zypper, pacman, apk, flatpak, snap, Homebrew | Software Update (`softwareupdate`), Homebrew | Windows Update (the Windows Update Agent), winget | pkg (FreeBSD); the rest named |
| Drive health (`drives`) | smartctl; NVMe log (nvme-cli); sysfs for the list | smartctl; diskutil (Verified or Failing) | Get-PhysicalDisk and its reliability counters; smartctl | smartctl (none on AIX) |
| Duplicates: one copy on disk | hard links and reflink clones (FIEMAP) | hard links and APFS clones | hard links (file IDs) | hard links |
| Ports | /proc, every program's when root | lsof | netstat -ano and tasklist | sockstat on FreeBSD; netstat elsewhere, without programs |
| Sleep (`sleep`) | the journal, systemd-inhibit, /sys/class/wakeup, /proc/acpi/wakeup | pmset log, assertions and sched | the System event log (wevtutil) and powercfg | not read yet |
| Permissions | Flatpak, Snap, programs with a camera or microphone open | TCC lists (Full Disk Access for the terminal) | consent store in the registry, with last use | none kept |
| ShareSafe | Samba (testparm, usershares), NFS exports, sshd, ports, Docker, ufw/firewalld/nftables | sharing -l, launchd's services, AirDrop, Media Sharing, socketfilterfw | Get-SmbShare, Remote Desktop, OpenSSH, firewall profiles, network category | smb4.conf, exports, sshd, pf/ipfw |
| Startup | systemd services and timers, your user units, cron @reboot, autostart | Launch Agents and Daemons (Login Items: not yet); Apple's own with `--all` | services, Run keys, Startup folders, tasks at logon; Windows' own with `--all` | rc.conf, shown only |

Protected paths are per system and checked without regard to case where the system ignores it,
after following links in the folders above (macOS's /etc is a link). macOS refuses /System, /Library,
/usr, /private/etc, /private/var and each ~/Library except Caches and Logs. Windows refuses
C:\Windows, Program Files, ProgramData, the Recycle Bin folder, page and hibernation files and each
AppData except Local\Temp. Whole home folders and top-level folders are refused everywhere but Linux,
where removing an old user's home is normal server work.

`grow` and `motd` say they work on Linux only and exit 3.
