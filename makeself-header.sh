cat << EOF  > "$archname"
#!/bin/sh
# This script was generated using Makeself $MS_VERSION
CRCsum=$crcsum
MD5=$md5sum
TMPROOT=\${TMPDIR:=/tmp}

label="$LABEL"
script="$SCRIPT"
scriptargs="$SCRIPTARGS"
targetdir="$archdirname"
keep=$KEEP

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

MS_Printf()
{
    \$print_cmd \$print_cmd_arg "\$1"
}

MS_Help()
{
    cat << EOH
Makeself version $MS_VERSION
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
  --keep                Do not erase target directory after running
			the embedded script
  --nox11               Do not spawn an xterm
  --target NewDirectory Extract in NewDirectory
EOH
}

MS_Check()
{
    MS_Printf "Verifying archive integrity..."
    if test \$CRCsum = "0000000000"; then
	test x\$2 = xy && echo " \$1 does not contain a CRC checksum."
    else
	sum1=\`tail +$SKIP \$1 | cksum | sed -e 's/ /Z/' -e 's/	/Z/' | cut -dZ -f1\`
	if test "\$sum1" = "\$CRCsum"; then
	    test x\$2 = xy && MS_Printf " Checksums are OK."
	else
	    echo "Error in checksums: \$sum1 is different from \$CRCsum"
	    exit 2;
	fi
    fi
    if test \$MD5 = "00000000000000000000000000000000"; then
	test x\$2 = xy && echo " \$1 does not contain an embedded MD5 checksum."
    else
	OLD_PATH=\$PATH
	PATH=\${GUESS_MD5_PATH:-"\$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_PATH=\`type -p md5sum\`
	MD5_PATH=\${MD5_PATH:-\`type -p md5\`}
	PATH=\$OLD_PATH
	if test -x "\$MD5_PATH"; then
	    md5sum=\`tail +$SKIP \$1 | "\$MD5_PATH" | cut -b-32\`;
	    if test "\$md5sum" != "\$MD5"; then
		echo "Error in MD5 checksums: \$md5sum is different from  \$MD5"
		exit 2
	    else
		test x\$2 = xy && MS_Printf " MD5 checksums are OK."
	    fi
	else
	    echo An embedded MD5 sum of the archive exists but no md5sum program was found in \$PATH
	    echo If you have md5sum on your system, you should try :
	    echo env GUESS_MD5_PATH=\"FirstDirectory:SecondDirectory:...\" \$0 -check
        fi
    fi
    echo " All good."
}

UnTAR()
{
    tar xvf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 \$$; }
}

finish=true
xterm_loop=
nox11=$NOX11

while true
do
    case "\$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    --info)
	echo Identification: "\$label"
	echo Target directory: "\$targetdir"
	echo Uncompressed size: $USIZE KB
	echo Compression: $COMPRESS
	echo Date of packaging: $DATE
	echo Built with Makeself version $MS_VERSION on $OSTYPE
	if test x\$script != x; then
	    echo Script run after extraction:
	    echo "    " \$script \$scriptargs
	fi
	if test x"$KEEP" = xy; then
	    echo "directory \$targetdir is permanent"
	else
	    echo "\$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --lsm)
cat << EOLSM
EOF
eval $LSM_CMD
cat << EOF  >> "$archname"
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: \$targetdir
	tail +$SKIP \$0  | $GUNZIP_CMD | tar tvf -
	exit 0
	;;
    --check)
	MS_Check "\$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=\${2:-.}
	shift 2
	;;
    --nox11)
	nox11=y
	shift
	;;
    --xwin)
	finish="echo Press Return to close this window...; read junk"
	xterm_loop=1
	shift
	;;
    -*)
	echo Unrecognized flag : "\$1"
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test "\$nox11" = "n"; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"\$DISPLAY" != x -a x"\$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm rxvt dtterm eterm Eterm kvt konsole aterm"
                for a in \$GUESS_XTERMS; do
                    if type \$a >/dev/null 2>&1; then
                        XTERM=\$a
                        break
                    fi
                done
                chmod a+x \$0 || echo Please add execution rights on \$0
                if test \`echo "\$0" | cut -c1\` = "/"; then # Spawn a terminal!
                    exec \$XTERM -title "\$label" -e "\$0" --xwin "\$@"
                else
                    exec \$XTERM -title "\$label" -e "./\$0" --xwin "\$@"
                fi
            fi
        fi
    fi
fi

if test "\$targetdir" = "."; then
    tmpdir="."
else
    if test "\$keep" = y; then
	echo "Creating directory \$targetdir"
	tmpdir="\$targetdir"
    else
	tmpdir="\$TMPROOT/selfgz\$\$"
    fi
    mkdir \$tmpdir || {
	echo 'Cannot create target directory' \$tmpdir >&2
	echo 'You should perhaps try option -target OtherDirectory' >&2
	eval \$finish
	exit 1
    }
fi

location="\`pwd\`"
if test x\$SETUP_NOCHECK != x1; then
    MS_Check "\$0"
fi

MS_Printf "Uncompressing \$label"
cd \$tmpdir
res=3
if test "\$keep" = n; then
    trap 'echo Signal caught, cleaning up > /dev/tty; cd \$TMPROOT; /bin/rm -rf \$tmpdir; eval \$finish; exit 15' 1 2 15
fi
if (cd "\$location"; tail +$SKIP \$0; ) | $GUNZIP_CMD | UnTAR | \
    (while read a; do MS_Printf .; done; echo; ); then
	(PATH=/usr/xpg4/bin:$PATH; chown -R \`id -u\` .;  chgrp -R \`id -g\` .)
	res=0
	if test x"\$script" != x; then
		if test x"\$verbose" = xy; then
			MS_Printf "OK to execute: \$script \$scriptargs \$* ? [Y/n] "
			read yn
			if test x"\$yn" = x -o x"\$yn" = xy -o x"\$yn" = xY; then
			    \$script \$scriptargs \$*; res=\$?;
			fi
		else
			\$script \$scriptargs \$*; res=\$?
		fi
		if test \$res != 0; then
		    echo "The program returned an error code (\$res)"
		fi
	fi
	if test "\$keep" = n; then
	    cd \$TMPROOT
	    /bin/rm -rf \$tmpdir
	fi
else
    echo "Unable to decompress \$0"
    eval \$finish; exit 1
fi
eval \$finish; exit \$res
EOF
