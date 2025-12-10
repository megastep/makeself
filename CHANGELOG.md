# Changelog

All notable changes to Makeself are documented here.

## 2.7.0

- Compression now precedes encryption so both can be enabled together.
- Signing passphrases are masked in stored metadata.
- Added coverage for combined encryption + compression flows.

## 2.6.0

- Added --preextract hook with --show-preextract, enabling scripted checks before extraction and full shUnit2 coverage.
- Introduced --comp-extra so archives can pass extra flags (e.g., --no-name) to any compressor, plus positive/negative tests.
- Documented SETUP_NOCHECK=1 to skip integrity verification; new regression test ensures behavior.

## 2.5.0

- Expanded support to NetBSD, OpenBSD, Busybox and other minimal distributions such as Alpine Linux.
- Added bzip3 compression support and expanded GPG arguments.

## 2.4.5

- Added --tar-format option to set the tar archive format (default is ustar).

## 2.4.4

- Fixed various compatibility issues (no longer use POSIX tar archives).
- GitHub Actions now check on Solaris and FreeBSD.

## 2.4.3

- Make explicit POSIX tar archives for increased compatibility.

## 2.4.2

- New --cleanup and --cleanup-args arguments for cleanup scripts.
- Added threading support for supported compressors.
- Added zstd compression support.

## 2.4.0

- Added optional support for SHA256 archive integrity checksums.

## 2.3.1

- Various compatibility updates.
- Added unit tests for Travis CI.
- New --tar-extra, --untar-extra, --gpg-extra, --gpg-asymmetric-encrypt-sign options.

## 2.3.0

- Support for archive encryption via GPG or OpenSSL.
- Added LZO and LZ4 compression support.
- Options to set the packaging date and stop the umask from being overridden.
- Optionally ignore disk space checks when extracting.
- New option to check for root permissions before extracting.

## 2.2.0

- Major new release with many bugfixes and user contributions.

## 2.1.6

- Replaced per-file dots with realtime progress percentage and a spinner.
- Added --noprogress to hide progress during decompression.
- Added --target to allow extracting directly to a target directory.

## 2.1.5

- MD5 detection consistent with the header code.
- Check for the presence of the archive directory.
- Added --encrypt for symmetric encryption through gpg (Eric Windisch).
- Added support for the digest command on Solaris 10 for MD5 checksums.
- Check for available disk space before extracting to the target directory (Andreas Schweitzer).
- Allow extraction to run asynchronously (patch by Peter Hatch).
- Use file descriptors internally to avoid error messages (patch by Kay Tiong Khoo).

## 2.1.4

- Fixed --info output.
- Generate random directory name when extracting files to . to avoid problems.
- Better handling of errors with wrong permissions for the directory containing the files.
- Avoid some race conditions; unset CDPATH to avoid problems if it is set.
- Better handling of dot files in the archive directory.

## 2.1.3

- Bug fixes with the command line when spawning terminals.
- Added --tar and --noexec for archives.
- Added --nomd5 and --nocrc to avoid creating checksums in archives.
- Embedded script now run through "eval".
- The --info output now includes the command used to create the archive.
- Added man page (contributed by Bartosz Fenski).

## 2.1.2

- Bug fixes; use head -n to avoid problems with POSIX conformance.

## 2.1.1

- Fixes related to the Unix compress command.
- Added better handling for compression availability.

## 2.1.0

- Multiple embedded tarballs, each with their own checksums.
- Archives can be updated with --append, reusing original settings.
- Improved checksum handling.
- Added --nochown option for archives.

## 2.0.1

- First public release of the new 2.0 branch.
- Introduced --copy to support installers that need to unmount media.

## 2.0

- Complete internal rewrite of Makeself.
- Vastly improved command-line parsing and maintenance by separating the stub from makeself.sh.
- Ported and tested across many Unix platforms.

## 1.5.x

- Numerous bugfixes and checksum improvements.
- Added --encrypt for symmetric encryption through gpg (Eric Windisch).
- Support for digest command on Solaris 10 for MD5 checksums.
- Disk-space checks before extraction.
- Added asynchronous extraction and improved error handling.
- Made part of the Loki Setup installer.

## 1.4

- Improved UNIX compatibility and automatic integrity checking.
- Support for LSM files to describe packages at runtime.

## 1.3

- Added support for no compression (`--nocomp`).
- Script is no longer mandatory.
- Automatic launch in an xterm.
- Optional verbose output.
- Added -target archive option to indicate where to extract files.

## 1.2

- Cosmetic updates.
- Support for bzip2 compression and non-temporary archives.

## 1.1

- Added ability to pass parameters through to the embedded script.

## 1.0

- Initial public release.
