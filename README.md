# remux
## RTSP to HLS remuxer and web server on RPI 3B+ (RPI OS Lite 64-bit)

---

*note: all steps are to be performed as root*

---

>This is the framework I came up with to convert 2 RTSP IP Camera streams to HLS along with a simple web page and [VideoJS](https://github.com/videojs/video.js) viewers.

>Created a ramdisk (`/mnt/ram`) to store the web page and ffmpeg output files for speed and SD card relief.

>Added [log2ram](https://github.com/azlux/log2ram) to further reduce the writes to the SD card.

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

6) Clone this repo to `/usr/local/src` then copy files to their proper places:
```
cd /usr/local/src
git clone https://github.com/dorkbrain/rtsp-remux
cd rtsp-remux
cp -rp !(README.md) /
chmod +x /usr/local/bin/startstream.sh
```

> Edit the `/etc/remux/camera{1,2}.json` files to use your camera authentication info and address.  Fields should be self explanitary.  ***The file names MUST match the service names created in the next step.***  You can tweak ffmpeg parameters here as well but that's beyond the scope.  Parameters gave me the best results with my camera and network.

<br/>

7) Reload the systemd daemon and enable the camera services:
```
systemctl daemon-reload
systemctl enable --now remux@camera{1,2}
```

<br/>

8) Disable the default Nginx site and enable remux:
```
rm /etc/nginx/sites-enabled/default
ln -fs /etc/nginx/sites-available/remux /etc/nginx/sites-enabled/remux
systemctl reload nginx
```

<br/>

9) Last of all, reboot to start logging to RAM instead of SD card:
```
reboot
```