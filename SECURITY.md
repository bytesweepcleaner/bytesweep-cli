# Security

ByteSweep CLI removes files and runs system tools, often as root, so we take reports seriously.

Please report a vulnerability privately to **support@bytesweep.app** with "Security" in the
subject, not in a public issue. Include the version (`bsweep version`), your system, and the
steps to reproduce it. We will answer within a few days and tell you when a fix is out.

Releases are signed: `bsweep update` and the install scripts refuse any download whose
checksum file doesn't carry the ByteSweep release signature (key fingerprint ending 54D5).
