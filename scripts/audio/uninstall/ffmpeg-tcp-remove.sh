#!/bin/bash
set -e
systemctl stop audio-stream.service || true
systemctl stop aloop.service || true
systemctl disable audio-stream.service || true
systemctl disable aloop.service || true
rm -f /etc/systemd/system/audio-stream.service
rm -f /etc/systemd/system/aloop.service
rm -f /usr/local/bin/audio-stream.sh
rm -f /root/ffmpeg.log
rm -f /root/ffmpeg.pid
systemctl daemon-reloads

#apt remove -y ffmpeg alsa-utils || true
#apt autoremove -y || true
