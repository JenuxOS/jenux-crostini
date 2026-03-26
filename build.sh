#!/bin/sh
if [ -z $arch ]||[ -z $preset ];then
if [ -z $arch ];then
echo arch is not set
else
echo arch: $arch
fi
if [ -z $preset ];then
echo preset is not set
else
echo preset: $preset
fi
echo environment error, see .venv.example, all vars must be set.
exit 1
fi
if echo $arch|grep -qw _detect_;then
export arch=`uname -m`
fi
export mydir=$PWD
cd $mydir
if [ -e $mydir/out ];then
sleep .01
else
mkdir -p $mydir/out
fi
if [ -e $mydir/$arch ];then
sleep .01
else
mkdir -p $mydir/$arch
fi
mount -o bind $mydir/$arch $mydir/$arch
cd $mydir/$arch
export url=`lynx --dump -listonly -nonumbers https://jenux.dev/ci|grep -w iso.zip|grep -w \`echo -en $arch|sed "s|aarch64|arm|g"\`-$preset|sed "s|jenux-$arch.iso|rootfs.tar|g"`
curl -L $url|bsdtar -xO|tar -x
cp $mydir/postinst .
arch-chroot . /postinst
mv *.tini $mydir/out
cd $mydir/out
umount $mydir/$arch
rm -rf $mydir/$arch
