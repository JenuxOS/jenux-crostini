#!/bin/sh
umask 022
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
truncate -s 20G $arch"-"$preset".img"
mkfs.btrfs $arch"-"$preset".img"
mount $arch"-"$preset".img" $mydir/$arch
cd $mydir/$arch
export url="https://jenux.dev/get?"$arch"-"$preset".rootfs"
while true;do
if curl -L $url|bsdunzip -p /dev/stdin rootfs.tar|tar -x;then
break
else
continue
fi
done
cp $mydir/postinst .
arch-chroot . /bin/rootfsprep
arch-chroot . /postinst
cd $mydir
cat $arch"-"$preset".img"|zstd -3 > $mydir/out/$arch"-"$preset".img".zst
umount $mydir/$arch
rm -rf $mydir/$arch $arch"-"$preset".img"
