#! /bin/sh
#
# makeself 1.5.4
#
# $Id: makeself.sh,v 1.12 2000-11-18 07:01:55 megastep Exp $
#
# Utility to create self-extracting tar.gz archives.
# The resulting archive is a file holding the tar.gz archive with
# a small Shell script stub that uncompresses the archive to a temporary
# directory and then executes a given script from withing that directory.
#
# Makeself home page: http://www.lokigames.com/~megastep/makeself/
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
#
# (C) 1998-2000 by Stéphane Peter <megastep@lokigames.com>
#
# This software is released under the terms of the GNU GPL
# Please read the license at http://www.gnu.org/copyleft/gpl.html
#
VERSION=1.5.4
GZIP_CMD="gzip -c9"
GUNZIP_CMD="gzip -cd"
KEEP=n
CURRENT=n
NOX11=n
COMPRESS=gzip
TAR_ARGS=cvf
if [ "$1" = --version ]; then
	echo Makeself version $VERSION
	exit 0
fi
if [ "$1" = --bzip2 ]; then
	if which bzip2 2>&1 > /dev/null; then
		GZIP_CMD="bzip2 -9"
		GUNZIP_CMD="bzip2 -d"
		COMPRESS=bzip2
		shift 1
	else
		echo Unable to locate the bzip2 program in your \$PATH.>&2
		exit 1
	fi
else
	if [ "$1" = --nocomp ]; then
		GZIP_CMD=cat; GUNZIP_CMD=cat; COMPRESS=none
		shift 1
	fi
fi
if [ "$1" = --notemp ]; then
	KEEP=y
	shift 1
	if [ "$1" = --current ]; then
		CURRENT=y
		shift 1
	fi
fi
if [ "$1" = --nox11 ]; then
	NOX11=y
	shift 1
fi
if [ "$1" = --follow ]; then
	TAR_ARGS=cvfh
	shift 1
fi
skip=147
if [ x"$1" = x--lsm -o x"$1" = x-lsm ]; then
	shift 1
   lsm_file=$1
   [ -r $lsm_file ] && {
     nl_supp=`cat $lsm_file | wc -l`
} ||  {
   echo "can't read LSM file " $lsm_file ;
  lsm_file="no_LSM";
  nl_supp=1; }
	shift 1
else
  lsm_file="no_LSM"
  nl_supp=1
fi
skip=`expr $skip + $nl_supp`
if [ "$KEEP" = n -a $# = 3 ]; then
	echo "Making a temporary archive with no embedded command does not make sense!"
	echo
	shift 1 # To force the command usage
fi
if [ $# -lt 3 ]; then
    echo "Usage: $0 [params] archive_dir file_name label [startup_script] [args]"
	echo "params can be one of those :"
	echo "    --version  : Print out Makeself version number and exit"
	echo "    --bzip2    : Compress using bzip2 instead of gzip"
	echo "    --nocomp   : Do not compress the data"
	echo "    --notemp   : The archive will create archive_dir in the"
	echo "                 current directory and uncompress in ./archive_dir"
	echo "    --current  : Used with --notemp, files will be extracted to the"
	echo "                 current directory."
    echo "    --follow   : Follow the symlinks in the archive"
	echo "    --nox11    : Disable automatic spawn of a xterm"
	echo "    --nowait   : Do not wait for user input after executing embedded program from an xterm"
	echo "    --lsm file : LSM file describing the package"
    echo Do not forget to give a fully qualified startup script name
    echo "(i.e. with a ./ prefix if inside the archive)."
    exit 1
fi

archdir=$1
archname=$2
# We don't really want to create an absolute directory...
archdirname=`basename "$1"`
USIZE=`du -ks $archdir | cut -f1`
DATE=`date`

# The following is the shell script stub code
echo '#! /bin/sh' > $archname
if [ $NOX11 = n ]; then
	skip=`expr $skip + 21`
fi
if [ $CURRENT = n ]; then
	skip=`expr $skip + 6`
fi
echo skip=$skip >> $archname
echo \# This script was generated using Makeself $VERSION >> $archname
echo 'CRCsum=0000000000' >> $archname
echo 'MD5=00000000000000000000000000000000' >> $archname
# echo lsm=\"$lsm_contents\" >> $archname
echo label=\"$3\" >> $archname
echo script=$4 >> $archname
[ x"$4" = x ] || shift 1
echo targetdir="$archdirname" >>$archname
shift 3
echo scriptargs=\"$*\" >> $archname
echo "keep=$KEEP" >> $archname

cat << EODF  >> $archname
TMPROOT=\${TMPDIR:=/tmp}
finish=true; xterm_loop=;
[ x"\$1" = x-xwin ] && {
 finish="echo Press Return to close this window...; read junk"; xterm_loop=1; shift 1;
}
if [ x"\$1" = "x-help" -o x"\$1" = "x--help" ]; then
  cat << tac
 1) Getting help or info about \$0 :
  \$0 --help   Print this message
  \$0 --info   Print embedded info : title, default target directory, embedded script ...
  \$0 --lsm    Print embedded lsm entry (or no LSM)
  \$0 --list   Print the list of files in the archive
  \$0 --check  Checks integrity of the archive
 
 2) Running \$0 :
  \$0 [options] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --keep                Do not erase target directory after running embedded script
  --target NewDirectory Extract in NewDirectory
tac
  exit 0;
fi
if [ x"\$1" = "x-lsm" -o x"\$1" = "x--lsm" ]; then
  cat << EOF_LSM
EODF
 if [ x"$lsm_file" = "xno_LSM" ]; then
    echo "no LSM" >> $archname
 else
    cat $lsm_file >> $archname
 fi
cat << EOF >> $archname
EOF_LSM
  exit 0;
fi
if [ "\$1" = "--info" ]; then
	echo Identification: \$label
	echo Target directory: \$targetdir
	echo Uncompressed size: $USIZE KB
	echo Compression: $COMPRESS
	echo Date of packaging: $DATE
	echo script run after extraction: \$script \$scriptargs
	[ x"\$keep" = xy ] && echo "directory \$targetdir is permanent" || echo "\$targetdir will be removed after extraction"
	exit 0;
fi
if [ "\$1" = "--list" ]; then
	echo Target directory: \$targetdir
	tail +\$skip \$0  | $GUNZIP_CMD | tar tvf -
	exit 0;
fi
if [ "\$1" = "--check" ]; then
sum1=\`tail +6 \$0 | cksum | sed -e 's/ /Z/' -e 's/	/Z/' | cut -dZ -f1\`
[ \$sum1 -ne \$CRCsum ] && {
  echo Error in checksums \$sum1 \$CRCsum
  exit 2;
}
if [ \$MD5 != "00000000000000000000000000000000" ]; then
# space separated list of directories
  [ x"\$GUESS_MD5_PATH" = "x" ] && GUESS_MD5_PATH="/usr/local/ssl/bin"
  MD5_PATH=""
  for a in \$GUESS_MD5_PATH; do
    if which \$a/md5 >/dev/null 2>&1 ; then
       MD5_PATH=\$a;
    fi
  done
  if [ -x \$MD5_PATH/md5 ]; then
    md5sum=\`tail +6 \$0 | \$MD5_PATH/md5\`;
    [ \$md5sum != \$MD5 ] && {
      echo Error in md5 sums \$md5sum \$MD5
      exit 2
    } || { echo check sums and md5 sums are ok; exit 0; }
  fi
  if [ ! -x \$MD5_PATH/md5 ]; then
      echo an embedded md5 sum of the archive exists but no md5 program was found in \$GUESS_MD5_PATH
      echo if you have md5 on your system, you should try :
      echo env GUESS_MD5_PATH=\"FirstDirectory SecondDirectory ...\" \$0 -check
  fi
else
  echo check sums are OK ; echo \$0 does not contain embedded md5 sum ;
fi
	exit 0;
fi
EOF

cat << EOF >> $archname
[ x"\$finish" = x ] && finish=true
parsing=yes
x11=y
while [ x"\$parsing" != x ]; do
    case "\$1" in
      --confirm) verbose=y; shift;;
      --keep) keep=y; shift;;
      --nox11)  x11=n; shift;;
      --target) if [ x"\$2" != x ]; then targetdir="\$2"; keep=y; shift 2; fi;;
      *) parsing="";;
    esac
done
EOF

if [ $NOX11 = n ]; then
cat << EOF >> $archname
if [ "\$x11" = "y" ]; then
    if ! tty -s; then                 # Do we have a terminal?
        if [ x"\$DISPLAY" != x -a x"\$xterm_loop" = x ]; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="dtterm eterm Eterm xterm rxvt kvt"
                for a in \$GUESS_XTERMS; do
                    if which \$a >/dev/null 2>&1; then
                        XTERM=\$a
                        break
                    fi
                done
                chmod a+x \$0 || echo Please add execution rights on \$0
                if [ \`echo "\$0" | cut -c1\` = / ]; then # Spawn a terminal!
                    exec \$XTERM -title "\$label" -e "\$0" -xwin "\$@"
                else
                    exec \$XTERM -title "\$label" -e "./\$0" -xwin "\$@"
                fi
            fi
        fi
    fi
fi
EOF
fi

if [ $CURRENT = n ]; then
cat << EOF >> $archname
if [ "\$keep" = y ]; then echo "Creating directory \$targetdir"; tmpdir=\$targetdir;
else tmpdir="\$TMPROOT/selfgz\$\$"; fi
mkdir \$tmpdir || {
        \$echo 'Cannot create target directory' \$tmpdir >&2
        \$echo 'you should perhaps try option -target OtherDirectory' >&2
		eval \$finish; exit 1;
}
EOF
else
cat << EOF >> $archname
tmpdir=.
EOF
fi
cat << EOF >> $archname
location=\`pwd\`
echo=echo; [ -x /usr/ucb/echo ] && echo=/usr/ucb/echo
\$echo -n Verifying archive integrity...
sum1=\`tail +6 \$0 | cksum | sed -e 's/ /Z/' -e 's/	/Z/' | cut -dZ -f1\`
[ \$sum1 -ne \$CRCsum ] && {
  \$echo Error in check sums \$sum1 \$CRCsum
  eval \$finish; exit 2;
}
echo OK
if [ \$MD5 != \"00000000000000000000000000000000\" ]; then
# space separated list of directories
  [ x\$GUESS_MD5_PATH = x ] && GUESS_MD5_PATH=\"/usr/local/ssl/bin\"
  MD5_PATH=\"\"
  for a in \$GUESS_MD5_PATH; do
    if which \$a/md5 >/dev/null 2>&1 ; then
       MD5_PATH=\$a;
    fi
  done
  if [ -x \$MD5_PATH/md5 ]; then
    md5sum=\`tail +6 \$0 | \$MD5_PATH/md5\`;
    [ \$md5sum != \$MD5 ] && {
      \$echo Error in md5 sums \$md5sum \$MD5
      eval \$finish; exit 2;
    }
  fi
fi
UnTAR() { tar xvf - || { echo Extraction failed. > /dev/tty; kill \$1; } ; }
\$echo -n "Uncompressing \$label"
cd \$tmpdir ; res=3
[ "\$keep" = y ] || trap 'echo Signal trapped > /dev/tty; cd \$TMPROOT; /bin/rm -rf \$tmpdir; eval \$finish; exit \$res'
if (cd \$location; tail +\$skip \$0; ) | $GUNZIP_CMD | UnTAR \$$ | \
 (while read a; do \$echo -n .; done; echo; ); then
	chown -Rf \`id -u\`.\`id -g\` .
    res=0; if [ x"\$script" != x ]; then
		if [ x"\$verbose" = xy ]; then
			\$echo "OK to execute: \$script \$scriptargs \$* ? [Y/n] "
			read yn
			[ x"\$yn" = x -o x"\$yn" = xy -o x"\$yn" = xY ] && { \$script \$scriptargs \$*; res=\$?; }
		else
			\$script \$scriptargs \$*; res=\$?
		fi
		[ \$res != 0 ] && echo "The program returned an error code (\$res)"
	fi
    [ "\$keep" = y ] || { cd \$TMPROOT; /bin/rm -rf \$tmpdir; }
else
  echo "Cannot decompress \$0"; eval \$finish; exit 1
fi
eval \$finish; exit \$res
END_OF_STUB
EOF

# Append the compressed tar data after the stub
echo Adding files to archive named \"$archname\"...
# (cd $archdir; tar cvf - *| $GZIP_CMD ) >> $archname && chmod +x $archname && ..
(cd $archdir; tar $TAR_ARGS - * | $GZIP_CMD ) >> $archname || { echo Aborting; exit 1; }
echo
echo >> $archname >&- ; # try to close the archive
# echo Self-extractible archive \"$archname\" successfully created.
sum1=`tail +6 $archname | cksum | sed -e 's/ /Z/' -e 's/	/Z/' | cut -dZ -f1`
# space separated list of directories
[ x"$GUESS_MD5_PATH" = "x" ] && GUESS_MD5_PATH="/usr/local/ssl/bin"
MD5_PATH=""
for a in $GUESS_MD5_PATH; do
  if which $a/md5 >/dev/null 2>&1 ; then
     MD5_PATH=$a;
  fi
done

tmpfile=${TMPDIR:=/tmp}/mkself$$
if [ -x $MD5_PATH/md5 ]; then
  md5sum=`tail +6 $archname | $MD5_PATH/md5`;
# echo md5sum $md5sum
  sed -e "s/^CRCsum=0000000000/CRCsum=$sum1/" -e "s/^MD5=00000000000000000000000000000000/MD5=$md5sum/" $archname > $tmpfile
else
  sed -e "s/^CRCsum=0000000000/CRCsum=$sum1/" $archname > $tmpfile
fi
mv $tmpfile $archname
chmod +x $archname
echo Self-extractible archive \"$archname\" successfully created.
