#!/bin/bash

for d in \
  android \
  boot/grub \
  boot/efi \
  cdrom \
  root \
  source; do
  mkdir -p $d
done

# setup autologin
sed -i 's@1:2345:respawn:/sbin/getty@1:2345:respawn:/sbin/getty -n -l /usr/sbin/autologin@g' /etc/inittab
# change default shell to bash
sed -i -r 's|^(root:.*:)/bin/d?a?sh$|\1/bin/bash|g' /etc/passwd

# Symlink kernel modules and firmwares
# manually because some of the packages
# may intentionally create these folders
rm -rf /lib/{firmware,modules}
ln -s /system/lib/modules /vendor/firmware /lib/

busybox --install -s /bin

# Additional setup
ln -s pcmanfm-qt /usr/bin/pcmanfm

# Enable dbus and udev services
update-rc.d dbus defaults
update-rc.d udev defaults
update-rc.d eudev defaults

# Remove /usr/sbin/policy-rc.d on Docker container
rm -rf \
  /etc/apt \
  /usr/include \
  /usr/lib/cmake \
  /usr/sbin/policy-rc.d \
  /usr/share/doc \
  /usr/share/doc-base \
  /usr/share/gtk-doc \
  /usr/share/info \
  /usr/share/man \
  /usr/share/man-db \
  /var/cache/* \
  /var/lib/apt \
  /var/lib/dpkg

find usr/lib/x86_64-linux-gnu -iname "*.cmake" -exec rm -f {} +

exit 0
