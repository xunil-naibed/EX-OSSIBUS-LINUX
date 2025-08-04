#!/bin/bash
####################################################################################################################
# boots with bios using syslinux
# EX-OSSIBUS-LINUX-BIOS v-0.0.01
# Copyright (c) 2025 [Developer: Richard P.G. Flood (CEO) | Company: Bird-Seed Farm, est. 2015]

####################################################################################################################
########################
# install dependencies
########################
# apt install bzip2 git make gcc libncurses-dev flex bison bc cpio libelf-dev libssl-dev syslinux dosfstools
####################################################################################################################
########################
# create build directory 
########################
 cd Q
 rm -rf boot-files
 rm -rf isoimage

 mkdir boot-files
 mkdir -p boot-files/initramfs
 mkdir isoimage

####################################################################################################################
########################
# cd into kernel
########################
 cd linux
####################################################################################################################

####################################################################################################################
########################
# build the kernel
########################
  make mrproper
  make defconfig
  yes "" | make oldconfig
  make ARCH=x86 bzImage -j$(nproc)
####################################################################################################################
########################
# copy kernel image
########################
 cp arch/x86/boot/bzImage $HOME/Q/boot-files
 cd ../
####################################################################################################################
########################
# cd into busybox
########################
 cd busybox
####################################################################################################################
########################
# configure busybox
########################
 make distclean defconfig
# Enable static linking
  sed -i "s|.*CONFIG_STATIC.*|CONFIG_STATIC=y|" .config

# Disable 'tc' to avoid broken compile
  sed -i "s/.*CONFIG_TC.*/# CONFIG_TC is not set/" .config

# Accept all default answers for new options
  yes "" | make oldconfig
####################################################################################################################
######################## 
# build busybox 
######################## 
make -j$(nproc)
####################################################################################################################
######################## 
# create initramfs
######################## 
make CONFIG_PREFIX=$HOME/Q/boot-files/initramfs install
cd $HOME/Q/boot-files/initramfs/
####################################################################################################################
######################## 
# Create necessary dirs
######################## 
mkdir -p dev proc sys
####################################################################################################################
######################## 
# Create /dev/console and /dev/null device nodes (critical!)
######################## 
 mknod -m 622 dev/console c 5 1
 mknod -m 666 dev/null c 1 3
####################################################################################################################
######################## 
# Create init script
######################## 
cat > init << 'EOF'
#!/bin/sh
mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sys /sys
clear
echo "" > /dev/console
echo "===========================" > /dev/console
echo "WELCOME TO EX-OSSIBUS-LINUX" > /dev/console
echo "===========================" > /dev/console
echo "" > /dev/console

exec /bin/sh

EOF

rm -f linuxrc
chmod +x init
####################################################################################################################
######################## 
# Pack initramfs cpio archive
######################## 
find . | cpio -o -H newc > ../init.cpio
cd $HOME/Q
 
####################################################################################################################
######################## 
# create a bootable 
# file system
########################  
  cp syslinux/bios/core/isolinux.bin isoimage
  cp syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 isoimage
  cp $HOME/Q/boot-files/bzImage $HOME/Q/boot-files/init.cpio isoimage
  
    cat > isoimage/isolinux.cfg <<EOF
DEFAULT linux
LABEL linux
  KERNEL bzImage
  APPEND initrd=init.cpio console=tty0 init=/init
EOF

####################################################################################################################
# compile the iso
######################## 
xorriso -as mkisofs \
  -o Ex-Ossibus-Linux-bios-ash.iso \
  -b isolinux.bin \
  -c boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  isoimage
####################################################################################################################
#
