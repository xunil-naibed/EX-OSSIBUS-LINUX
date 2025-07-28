

currently available for download:

the bootable bios version of the iso file for use in your choice of vm software.. 
i suggest qemu

here's a command i myself use to run this iso,, (as an example)
qemu-system-x86_64 -cdrom Ex-Ossibus-Linux-bios.iso -m 512M

make sure you install qemu ...
for debian users, use the command below...
apt install qemu*
which is overkill for sure.

or

use your prefered package manager and vm to boot this iso in a virtual environment.

this will not boot using uefi.. it uses bios only

coming soon!

the build script!!! 
and 
source code!!!

it's super easy to build! stay tuned!
