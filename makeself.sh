#!/bin/sh
#
# Makeself version 2.x
#  by Stephane Peter <megastep@megastep.org>
#
# $Id: makeself.sh,v 1.28 2002-10-19 07:41:11 megastep Exp $
#
# Utility to create self-extracting tar.gz archives.
# The resulting archive is a file holding the tar.gz archive with
# a small Shell script stub that uncompresses the archive to a temporary
# directory and then executes a given script from withing that directory.
#
# Makeself home page: http://www.megastep.org/makeself/
#
# Version 2.0 is a rewrite of version 1.0 to make the code easier to read and maintain.
#
# Version history :
# - 1.0 : Initial public release
# - 1.1 : The archive can be passed parameters that will be passed on to
#         the embedded script, thanks to John C. Quillan
# - 1.2 : Package distribution, bzip2 compression, more command line options,
#         support for non-temporary archives. Ideas thanks to Francois Petitjean
# - 1.3 : More patches from Bjarni R. Einarsson and Francois Petitjean:
#         Support for no compression (--nocomp), script is no longer mandatory,
#         automatic launch in an xterm, optional verbose output, and -target 
#         archive option to indicate where to extract the files.
# - 1.4 : Improved UNIX compatibility (Francois Petitjean)
#         Automatic integrity checking, support of LSM files (Francois Petitjean)
# - 1.5 : Many bugfixes. Optionally disable xterm spawning.
# - 1.5.1 : More bugfixes, added archive options -list and -check.
# - 1.5.2 : Cosmetic changes to inform the user of what's going on with big 
#           archives (Quake III demo)
# - 1.5.3 : Check for validity of the DISPLAY variable before launching an xterm.
#           More verbosity in xterms and check for embedded command's return value.
#           Bugfix for Debian 2.0 systems that have a different "print" command.
# - 1.5.4 : Many bugfixes. Print out a message if the extraction failed.
# - 1.5.5 : More bugfixes. Added support for SETUP_NOCHECK environment variable to
#           bypass checksum verification of archives.
# - 1.6.0 : Compute MD5 checksums with the md5sum command (patch from Ryan Gordon)
# - 2.0   : Brand new rewrite, cleaner architecture, separated header and UNIX ports.
# - 2.0.1 : Added --copy
#
# (C) 1998-2002 by Stéphane Peter <megastep@megastep.org>
#
# This software is released under the terms of the GNU GPL
# Please read the license at http://www.gnu.org/copyleft/gpl.html
#

MS_VERSION=2.0.1

# Procedures

MS_Usage()
{
    echo "Usage: $0 [params] archive_dir file_name label [startup_script] [args]"
    echo "params can be one or more of the following :"
    echo "    --version | -v  : Print out Makeself version number and exit"
    echo "    --help | -h     : Print out this help message"
    echo "    --gzip          : Compress using gzip (default if detected)"
    echo "    --bzip2         : Compress using bzip2 instead of gzip"
    echo "    --compress      : Compress using the UNIX 'compress' command"
    echo "    --nocomp        : Do not compress the data"
    echo "    --notemp        : The archive will create archive_dir in the"
    echo "                      current directory and uncompress in ./archive_dir"
    echo "    --copy          : Upon extraction, the archive will first copy itself to"
    echo "                      a temporary directory"
    echo "    --current       : Files will be extracted to the current directory."
    echo "                      Implies --notemp."
    echo "    --header file   : Specify location of the header script"
    echo "    --follow        : Follow the symlinks in the archive"
    echo "    --nox11         : Disable automatic spawn of a xterm"
    echo "    --nowait        : Do not wait for user input after executing embedded"
    echo "                      program from an xterm"
    echo "    --lsm file      : LSM file describing the package"
    echo
    echo "Do not forget to give a fully qualified startup script name"
    echo "(i.e. with a ./ prefix if inside the archive)."
    exit 1
}

# Default settings
if type gzip 2>&1 > /dev/null; then
	GZIP_CMD="gzip -c9"
	GUNZIP_CMD="gzip -cd"
	COMPRESS=gzip
else
	GZIP_CMD="compress -c"
	GUNZIP_CMD="compress -cd"
	COMPRESS=Unix
fi
KEEP=n
CURRENT=n
NOX11=n
COPY=none
TAR_ARGS=cvf
HEADER=`dirname $0`/makeself-header.sh

# LSM file stuff
LSM_LINES=1
LSM_CMD="echo No LSM. >> \"\$archname\""

while true
do
    case "$1" in
    --version | -v)
	echo Makeself version $MS_VERSION
	exit 0
	;;
    --bzip2)
	GZIP_CMD="bzip2 -9"
	GUNZIP_CMD="bzip2 -d"
	COMPRESS=bzip2
	shift
	;;
    --gzip)
	GZIP_CMD="gzip -c9"
	GUNZIP_CMD="gzip -cd"
	COMPRESS=gzip
	shift
	;;
    --compress)
	GZIP_CMD="compress -c"
	GUNZIP_CMD="compress -cd"
	COMPRESS=Unix
	shift
	;;
    --nocomp)
	GZIP_CMD="cat"
	GUNZIP_CMD="cat"
	COMPRESS=none
	shift
	;;
    --notemp)
	KEEP=y
	shift
	;;
    --copy)
	COPY=copy
	shift
	;;
    --current)
	CURRENT=y
	KEEP=y
	shift
	;;
    --header)
	HEADER="$2"
	shift 2
	;;
    --follow)
	TAR_ARGS=cvfh
	shift
	;;
    --nox11)
	NOX11=y
	shift
	;;
    --nowait)
	shift
	;;
    --lsm)
	LSM_LINES=`cat "$2" | wc -l`
	LSM_CMD="cat \"$2\" >> \"\$archname\""
	shift 2
	;;
	-h | --help)
	MS_Usage
	;;
    -*)
	echo Unrecognized flag : "$1"
	MS_Usage
	;;
    *)
	break
	;;
    esac
done

if test "$KEEP" = n -a $# = 3; then
    echo "ERROR: Making a temporary archive with no embedded command does not make sense!"
    echo
    MS_Usage
fi
if test $# -lt 3; then
    MS_Usage
fi

if test "$KEEP" = n -a "$CURRENT" = y; then
    echo "ERROR: It is A VERY DANGEROUS IDEA to try to combine --notemp and --current."
    exit 1
fi

if test -f $HEADER; then
    SKIP=`cat $HEADER|wc -l`
    # There are 5 extra lines in header.sh
    SKIP=`expr $SKIP - 5 + $LSM_LINES`
    echo Header is $SKIP lines long
else
    echo "Unable to open header file: $HEADER"
    exit 1
fi

archdir="$1"
archname="$2"
# We don't really want to create an absolute directory...
if test "$CURRENT" = y; then
    archdirname="."
else
    archdirname=`basename "$1"`
fi
LABEL="$3"
SCRIPT="$4"
test x$SCRIPT = x || shift 1
shift 3
SCRIPTARGS="$*"

echo
if test -f "$archname"; then
    echo "WARNING: Overwriting existing file: $archname"
fi

USIZE=`du -ks $archdir | cut -f1`
DATE=`LC_ALL=C date`
tmpfile="${TMPDIR:=/tmp}/mkself$$"

echo About to compress $USIZE KB of data...
echo Adding files to archive named \"$archname\"...
(cd "$archdir"; tar $TAR_ARGS - * | $GZIP_CMD ) >> "$tmpfile" || { echo Aborting; rm -f "$tmpfile"; exit 1; }
echo >> "$tmpfile" >&- # try to close the archive

# Compute the checksums

md5sum=00000000000000000000000000000000
crcsum=`cat "$tmpfile" | cksum | sed -e 's/ /Z/' -e 's/	/Z/' | cut -dZ -f1`

# Try to locate a MD5 binary
OLD_PATH=$PATH
PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
MD5_PATH=`type -p md5sum`
MD5_PATH=${MD5_PATH:-`type -p md5`}
PATH=$OLD_PATH
if test -x "$MD5_PATH"; then
	md5sum=`cat "$tmpfile" | "$MD5_PATH" | cut -b-32`;
	echo "CRC: $crcsum"
	echo "MD5: $md5sum"
else
	echo "CRC: $crcsum"
	echo "MD5: none, md5sum binary not found"
fi

# Generate the header
. $HEADER

# Append the compressed tar data after the stub
echo
cat "$tmpfile" >> "$archname"
chmod +x "$archname"
echo Self-extractible archive \"$archname\" successfully created.
rm -f "$tmpfile"
