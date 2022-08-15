#!/bin/bash
if [[ -z "$1" ]]; then
  echo "Usage: $0 </path/to/camera.conf>"
  exit 1
fi

. "$1"

rtspurl="rtsp://${cam_user}:${cam_pass}@${cam_host}${cam_path}"
ffcmd="ffmpeg -i ${rtspurl} ${ffoptions[@]} ${web_path}/${cam_name}.m3u8"

sleep 10

if [[ ! -f ${web_path}/index.html ]]; then
  mkdir -p "${web_path}"
  ln -s /etc/remux/index.html "${web_path}"/index.html
fi

cd "${web_path}"
echo "${ffcmd}"

while :; do
  ${ffcmd}
  sleep 3
done