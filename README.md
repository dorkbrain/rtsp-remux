# remux
RTSP to HLS remuxer and web server on RPI 3B+ (RPI OS Lite 64-bit)

html, m3u8 playlist, and video files served up in a ramdisk

Start by making sure the Pi OS is up to date and clean:
```
apt update && apt upgrade -y && apt autoremove -y
```

Install necessary packages:
```
apt install nginx nginx-extras ffmpeg* jq
```

Create the ramdisk, add it to the fstab, and mount it:
```
mkdir -p /mnt/ram
echo "tmpfs	/mnt/ram	tmpfs	rw,mode=1777,size=256m,nosuid,nodev,noatime	0	0" >> /etc/fstab
mount -a
```

Create directory structure for remux config:
```
mkdir -p /etc/remux/html
```

Copy all static files where they need to go from this repo:
```
cp -rpv * /
```

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