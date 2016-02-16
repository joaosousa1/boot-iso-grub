## Boot-Ubuntu-daily-live-ISO-GRUB2

Shell script to update (sync) and boot Ubuntu-daily-live.ISO from GRUB2

Need sudo permissions only in the first run (install dependencies and add custom menu entry on grub).

For more details see script comments

**Reverting changes made by Boot-Ubuntu-daily-live-ISO-GRUB2.sh script:**

>cd /etc/grub.d/

>sudo rm -f 42_ubuntu-daily-live

>sudo update-grub

