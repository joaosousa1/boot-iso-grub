#!/bin/bash
#	Script to update and boot Ubuntu daily-live ISO with GRUB2
#	Autor João Sousa tuxmind.blogspot.com
#	Version 0.2 testado no Ubuntu 22.04 LTS
#	Update 2022-04-17

### Find partition uuid where the iso file is
DEVICE=`df -h . | tail -1 | cut -d" " -f1`
ROOTUUID=`sudo blkid $DEVICE | awk -F 'UUID="' '{print $2}' | cut -d\" -f1`

### Install curl and zsync (Add repo "universe")
which curl || sudo apt-get install -y curl
which zsync || (sudo apt-get update; sudo add-apt-repository universe; sudo apt-get update; sudo apt-get install -y zsync)

### Find last "daily-live" codename (future URL changes will break this :( send me your feedback if you know a better way to do this :P )
codename=`curl -s https://cdimage.ubuntu.com/daily-live/current/SHA256SUMS | head -1 | cut -d* -f2 | cut -d- -f1`

cd

### zsync download/update ISO file
zsync http://cdimage.ubuntu.com/daily-live/current/$codename-desktop-amd64.iso.zsync && echo "Image $codename-desktop-amd64.iso is update"

### Remove simbolic link (only if exist)
rm -f Ubuntu-desktop-amd64.iso

### Simbolic link to Ubuntu-desktop-arm64.iso
ln -s $codename-desktop-amd64.iso Ubuntu-desktop-amd64.iso

### Separate home partition?
RAIZ=`echo "/$USER"`
### Or... same partition?
[ `df / | tail -1 | cut -d" " -f1` == `df /home | tail -1 | cut -d" " -f1` ] && RAIZ=`echo "/home/$USER"`

### Created "42_ubuntu-daily-live" (if doesn't exist)
if [ -e /etc/grub.d/42_ubuntu-daily-live ];
then

echo "42_ubuntu-daily-live ok"

else

### Add new boot option to Grub2
cat > 42_ubuntu-daily-live << EOF
#!/bin/sh
exec tail -n +3 \$0

menuentry "Ubuntu $codename Daily Live" {
insmod part_gpt
insmod ext2
if [ x$feature_platform_search_hint = xy ]; then
  search --no-floppy --fs-uuid --set=root  $ROOTUUID
else
  search --no-floppy --fs-uuid --set=root $ROOTUUID
fi
set isofile="$RAIZ/Ubuntu-desktop-amd64.iso"
loopback loop \$isofile
linux (loop)/casper/vmlinuz root=UUID=$ROOTUUID boot=casper iso-scan/filename=\$isofile noprompt quiet splash --
initrd (loop)/casper/initrd.lz
}
EOF

### Move file "42_ubuntu-daily-live" to /etc/grub.d
sudo mv 42_ubuntu-daily-live /etc/grub.d/42_ubuntu-daily-live

### Change permissions
sudo chmod +x /etc/grub.d/42_ubuntu-daily-live

### Update Grub menu list
sudo update-grub

fi
