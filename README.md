# remux
RTSP to HLS remuxer and web server on RPI 3B+ (RPI OS Lite 64-bit)

html, m3u8 playlist, and video files served up in a ramdisk

(note: all steps are to be performed as root)

Start by making sure the Pi OS is up to date and clean:
```
apt update && apt upgrade -y && apt autoremove -y
```

Add log2ram repository and update apt:
```
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | tee /etc/apt/sources.list.d/azlux.list
wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
apt update
```

Install necessary packages:
```
apt install nginx nginx-extras ffmpeg* jq log2ram

```

Configure log2ram size and update logrotate to cut back on logs:
```
sed 's/SIZE=40M/SIZE=128M/g' -i /etc/log2ram.conf
sed -E 's/rotate .*/rotate 3/g; s/(monthly|weekly)/daily/g' -i /etc/logrotate.d/*
```

Create the ramdisk, add it to the fstab, and mount it:
```
mkdir -p /mnt/ram
echo "tmpfs /mnt/ram tmpfs rw,mode=1777,size=256m,nosuid,nodev,noatime 0 0" >> /etc/fstab
mount -a
```

Create directory structure for remux config:
```
mkdir -p /etc/remux/html
```

***This is when you should copy all of the files in this repo to their proper place***

Reload the systemd daemon and enable the camera services:
```
systemctl datemon-reload
systemctl enable --now {deck,porch}cam1
```

Disable the default Nginx site and enable remux:
```
rm /etc/nginx/sites-enabled/default
ln -fs /etc/nginx/sites-available/remux /etc/nginx/sites-enabled/remux
systemctl reload nginx
```

Last of all, reboot to start logging to RAM instead of SD card:
```
reboot
```