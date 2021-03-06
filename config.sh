#!/bin/bash

REPO=${REPO:-./repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml &&
	$REPO sync $sync_flags
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

case `uname` in
"Darwin")
	# Should also work on other BSDs
	CORE_COUNT=`sysctl -n hw.ncpu`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"git://github.com/ik3ch/b2g-manifest"}
BRANCH=${BRANCH:-master}

while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q)
		sync_flags="$sync_flags $1"
		shift
		;;
	--help|-h)
		# The main case statement will give a usage message.
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	git branch -m $BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1 >> .tmp-config

case "$1" in
"galaxy-s2")
	echo DEVICE=galaxys2 >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus")
	echo DEVICE=maguro >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus-ja")
	echo DEVICE=maguro >> .tmp-config &&
	echo LUNCH=full_maguro-eng >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus-jc")
	echo DEVICE=maguro >> .tmp-config &&
	echo LUNCH=full_maguro-eng >> .tmp-config &&
	repo_sync $1
	;;

"nexus-4")
	echo DEVICE=mako >> .tmp-config &&
	repo_sync nexus-4
	;;

"celox")
	echo DEVICE=celox >> .tmp-config &&
	repo_sync $1
	;;

"optimus-l5")
	echo DEVICE=m4 >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s")
	echo DEVICE=crespo >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s-ja")
	echo DEVICE=crespo >> .tmp-config &&
	echo LUNCH=full_crespo-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s-jc")
	echo DEVICE=crespo >> .tmp-config &&
	echo LUNCH=full_crespo-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s-4g")
	echo DEVICE=crespo4g >> .tmp-config &&
	repo_sync $1
	;;

"otoro"|"unagi"|"keon"|"inari"|"leo"|"hamachi"|"peak"|"helix"|"wasabi")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"keon-ja")
	echo DEVICE=keon >> .tmp-config &&
	echo LUNCH=full_keon-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"keon-jc")
	echo DEVICE=keon >> .tmp-config &&
	echo LUNCH=full_keon-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"peak-ja")
	echo DEVICE=peak >> .tmp-config &&
	echo LUNCH=full_peak-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"peak-jc")
	echo DEVICE=peak >> .tmp-config &&
	echo LUNCH=full_peak-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"tara")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync $1
	;;

"pandaboard")
	echo DEVICE=panda >> .tmp-config &&
	repo_sync $1
	;;

"emulator"|"emulator-jb")
	echo DEVICE=generic >> .tmp-config &&
	echo LUNCH=full-eng >> .tmp-config &&
	repo_sync $1
	;;

"emulator-x86"|"emulator-x86-jb")
	echo DEVICE=generic_x86 >> .tmp-config &&
	echo LUNCH=full_x86-eng >> .tmp-config &&
	repo_sync emulator
	;;

*)
	echo "Usage: $0 [-cdflnq] (device name)"
	echo "Flags are passed through to |./repo sync|."
	echo
	echo Valid devices to configure are:
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - galaxy-nexus-ja
	echo - galaxy-nexus-jc
	echo - nexus-4
	echo - celox
	echo - nexus-s
	echo - nexus-s-ja
	echo - nexus-s-jc
	echo - nexus-s-4g
	echo - otoro
	echo - unagi
	echo - inari
	echo - keon
	echo - keon-ja
	echo - keon-jc
	echo - peak
	echo - peak-ja
	echo - peak-jc
	echo - leo
	echo - hamachi
	echo - helix
	echo - wasabi
	echo - tara
	echo - pandaboard
	echo - emulator
	echo - emulator-jb
	echo - emulator-x86
	echo - emulator-x86-jb
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
