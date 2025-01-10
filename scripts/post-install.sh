#!/bin/bash

# Copy grub2 theme
mv /usr/share/grub/themes /iso/boot/grub
ln -s /cdrom/boot/grub/themes /usr/share/grub

# Generate a grub-rescue iso so we can use it as the base for the iso
grub-mkrescue \
  --themes="$(find /iso/boot/grub/themes -mindepth 1 -maxdepth 1 -type d -print -quit)" \
  -o /grub-rescue.iso \
  /iso
rm -rf /iso

# Generate initrd template
mkdir -p /initrd_lib/usr/{bin,lib,lib64}
ln -st /initrd_lib usr/{bin,lib,lib64}

# Copy binaries and libraries
find_dep() { ldd "$1" | awk '{print $3}' | xargs; }
for b in mount.ntfs-3g dmidecode; do
  b=$(which $b)
  cp -t /initrd_lib/bin $b
  cp -t /initrd_lib/lib $(find_dep "$b")
done

# Busybox is explicitly handled
cp -t /initrd_lib/bin /usr/share/bliss/busybox
cp -t /initrd_lib/lib $(find_dep /initrd_lib/bin/busybox)

# Linker
cp -t /initrd_lib/bin /bin/ld.so
cp -t /initrd_lib/lib /usr/lib/*/ld-linux-x86-64.so.*
cp -t /initrd_lib/lib64 /usr/lib64/ld-linux-x86-64.so.*

# Wrap initrd up
tar -czvf /initrd_lib.tar.gz /initrd_lib

exit 0
