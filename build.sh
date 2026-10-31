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
if [ -e /.dockerenv ];then
mount -t proc /proc /proc
mount -t devtmpfs /dev /dev
mount -t sysfs /sys /sys
if [ -e /proc/sys/fs/binfmt_misc/ ];then
sleep .01
else
mkdir -p /proc/sys/fs/binfmt_misc/
fi
if mountpoint -q /proc/sys/fs/binfmt_misc/;then
sleep .01
else
mount -t binfmt_misc /proc/sys/fs/binfmt_misc/ /proc/sys/fs/binfmt_misc/
fi
for f in `ls /lib/binfmt.d/*`;do
/lib/systemd/systemd-binfmt  $f
done
fi
export mydir=$PWD
cd $mydir
if [ -e $mydir/out ];then
sleep .01
else
mkdir -p $mydir/out
fi
if [ -e $mydir/$arch/$preset ];then
sleep .01
else
mkdir -p $mydir/$arch/$preset
fi
truncate -s 20G $arch"-"$preset".img"
mkfs.btrfs $arch"-"$preset".img"
mount $arch"-"$preset".img" $mydir/$arch/$preset
cd $mydir/$arch/$preset
export url="https://jenux.dev/get?"$arch"-live-"$preset".rootfs"
while true;do
if curl -L $url|bsdunzip -I UTF-8 -O UTF-8 -p /dev/stdin rootfs.tar|tar -x;then
break
else
continue
fi
done
cp $mydir/postinst $mydir/$arch/$preset
chmod 755 $mydir/$arch/$preset/postinst
arch-chroot $mydir/$arch/$preset /bin/sh /postinst
rm $mydir/$arch/$preset/postinst
cd $mydir
umount $mydir/$arch/$preset
rm -rf $mydir/$arch/$preset
cat $arch"-"$preset".img"|zstd -3 > $mydir/out/$arch"-"$preset".img".zst
rm $arch"-"$preset".img"
