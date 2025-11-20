#!/bin/bash
set -e
systemctl stop sox-stream.service || true
systemctl stop aloop.service || true
systemctl disable sox-stream.service || true
systemctl disable aloop.service || true
rm -f /etc/systemd/system/sox-stream.service
rm -f /etc/systemd/system/aloop.service
rm -f /usr/local/bin/sox-stream.sh
rm -f /etc/asound.conf
systemctl daemon-reload

#apt remove -y sox alsa-utils || true
#apt autoremove -y || true
