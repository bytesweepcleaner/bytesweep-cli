#!/bin/sh
# curl -fsSL https://bytesweep.app/install-cli.sh | sudo sh
# Any Unix: Linux, macOS, FreeBSD, OpenBSD, NetBSD, DragonFly, Solaris, illumos, AIX.
# One file in /usr/local/bin. It checks the published checksum, and on a nearly
# full disk it uses memory, not /tmp, if it can. Windows: install.ps1.
set -eu
BASE=https://bytesweep.app/downloads
case "$(uname -s)" in
  Linux) OS=linux ;; Darwin) OS=mac ;; FreeBSD) OS=freebsd ;; OpenBSD) OS=openbsd ;; NetBSD) OS=netbsd ;;
  DragonFly) OS=dragonfly ;; AIX) OS=aix ;;
  SunOS) if uname -o 2>/dev/null | grep -qi illumos; then OS=illumos; else OS=solaris; fi ;;
  *) echo "No ByteSweep build for $(uname -s) yet." >&2; exit 1 ;;
esac
M=$(uname -m); [ "$OS" = aix ] && M=ppc64
case "$M" in
  x86_64|amd64|i86pc) A=x86_64 ;;
  aarch64|arm64) if [ "$OS" = linux ]; then A=aarch64; else A=arm64; fi ;;
  armv7*|armv8l) A=armv7 ;; i386|i686) A=i386 ;;
  riscv64|ppc64le|s390x|loongarch64|ppc64) A=$M; [ "$M" = loongarch64 ] && A=loong64 ;;
  *) echo "No ByteSweep build for $M yet." >&2; exit 1 ;;
esac
[ "$(id -u)" = 0 ] || { echo "Run with sudo." >&2; exit 1; }
NAME="bsweep-$OS-$A"
D=/dev/shm; [ -w "$D" ] || D=${TMPDIR:-/tmp}
T="$D/bsweep.$$"; trap 'rm -f "$T" "$T.sums"' EXIT
get() { if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"; elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"; else ftp -o "$2" "$1"; fi; }
sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1"; elif command -v sha256 >/dev/null 2>&1; then sha256 -q "$1"; else digest -a sha256 "$1"; fi | cut -d' ' -f1; }
get "$BASE/$NAME" "$T"
get "$BASE/bsweep-SHA256SUMS.txt" "$T.sums"
WANT=$(grep " $NAME\$" "$T.sums" | cut -d' ' -f1)
GOT=$(sha "$T")
[ -n "$WANT" ] && [ "$WANT" = "$GOT" ] || { echo "Checksum doesn't match; nothing installed." >&2; exit 1; }
mkdir -p /usr/local/bin
cp "$T" /usr/local/bin/bsweep.new && chmod 755 /usr/local/bin/bsweep.new && mv /usr/local/bin/bsweep.new /usr/local/bin/bsweep
echo "Installed. Run: sudo bsweep"
