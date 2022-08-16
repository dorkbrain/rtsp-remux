# remux
## RTSP to HLS remuxer and web server on RPI 3B+ (RPI OS Lite 64-bit)

### html, m3u8 playlist, and video files served up in a ramdisk to reduce SD card strain

---

*note: all steps are to be performed as root*

---

In this demo I have a simple web page with 2 cameras (camer1 and camera2).

<br/>

1) Start by making sure the Pi OS is up to date and clean:
```
apt update && apt upgrade -y && apt autoremove -y
```

<br/>

2) Add log2ram repository and update apt:
```
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | tee /etc/apt/sources.list.d/azlux.list
wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
apt update
```

<br/>

3) Install necessary packages:
```
apt install nginx nginx-extras ffmpeg* jq log2ram
```

<br/>

4) Configure log2ram size and update logrotate to cut back on logs:
```
sed 's/SIZE=40M/SIZE=128M/g' -i /etc/log2ram.conf
sed -E 's/rotate .*/rotate 3/g; s/(monthly|weekly)/daily/g' -i /etc/logrotate.d/*
```

<br/>

5) Create the ramdisk, add it to the fstab, and mount it:
```
mkdir -p /mnt/ram
echo "tmpfs /mnt/ram tmpfs rw,mode=1777,size=256m,nosuid,nodev,noatime 0 0" >> /etc/fstab
mount -a
```

<br/>

6) Create directory structure for remux config:
```
mkdir -p /etc/remux/html
```

<br/>

7) Clone this repo to `/usr/local/src` then copy files to their proper places:
```
cd /usr/local/src
git clone https://github.com/dorkbrain/rtsp-remux
cd rtsp-remux
cp -rp !(README.md) /
chmod +x /usr/local/bin/startstream.sh
```

> Edit the `/etc/remux/camera{1,2}.json` files to use your camera authentication info and address.  Fields should be self explanitary.  ***The file names MUST match the service names created in the next steps.***  You can tweak ffmpeg parameters here as well but that's beyond the scopy of this repo.

<br/>

8) Reload the systemd daemon and enable the camera services:
```
systemctl daemon-reload
systemctl enable --now remux@camera{1,2}
```

<br/>

9) Disable the default Nginx site and enable remux:
```
rm /etc/nginx/sites-enabled/default
ln -fs /etc/nginx/sites-available/remux /etc/nginx/sites-enabled/remux
systemctl reload nginx
```

<br/>

10) Last of all, reboot to start logging to RAM instead of SD card:
```
reboot
```