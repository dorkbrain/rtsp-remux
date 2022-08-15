#!/bin/bash
if [[ -z "$1" ]]; then
  echo "Usage: $0 </path/to/camera.conf>"
  exit 1
fi

# Import camera config
cam_name="$( jq -r '.cam_name' <"$1")"
cam_user="$( jq -r '.cam_user' <"$1")"
cam_pass="$( jq -r '.cam_pass' <"$1")"
cam_host="$( jq -r '.cam_host' <"$1")"
cam_port="$( jq -r '.cam_port' <"$1")"
cam_path="$( jq -r '.cam_path' <"$1")"
source_html="$( jq -r '.source_html' <"$1")"
web_path="$( jq -r '.web_path' <"$1")"
ffoptions="$( jq -r '.ffoptions | join(" ")' <"$1" )"

# Construct RTSP URL and ffmpeg command line
rtspurl="rtsp://${cam_user}:${cam_pass}@${cam_host}${cam_path}"
ffcmd="ffmpeg -i ${rtspurl} ${ffoptions} ${web_path}/${cam_name}.m3u8"

# Sleep 10 seconds to allow system to settle down during boot or service restart
echo "In 10 seconds will execute:"
echo "  ${ffcmd}"
sleep 10

# Make sure html root path exists
if [[ ! -d ${web_path} ]]; then
  mkdir -p ${web_path}
fi

# (re-)link any source files to the RAM disk
for h in ${source_html}/*; do
  ln -fs $h ${web_path}/$(basename $h)
done

cd "${web_path}"

# Run ffmpeg in an endless loop to reconnect after any failures
while :; do
  ${ffcmd}
  sleep 3
done