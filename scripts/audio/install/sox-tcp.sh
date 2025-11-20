#!/bin/bash
set -e
apt install alsa-utils sox -y
cat >/etc/systemd/system/aloop.service <<EOF
[Unit]
Description=ALSA Loopback Device (snd-aloop)
DefaultDependencies=no
Before=sound.target

[Service]
Type=oneshot
ExecStart=/sbin/modprobe snd-aloop

[Install]
WantedBy=sound.target
EOF
cat >/etc/asound.conf <<EOF
pcm.!default {
    type plug
    slave.pcm "loop_capture_resampled"
}

pcm.loop_capture {
    type hw
    card Loopback
    device 1
    subdevice 0
}

pcm.loop_capture_resampled {
    type rate
    slave {
        pcm "loop_capture"
        rate 48000
    }
}
EOF
cat >/usr/local/bin/sox-stream.sh <<EOF
#!/bin/bash
set -e

DEVICE="loop_capture_resampled"

exec sox -q -t alsa \$DEVICE -r 48000 -c 2 -b 16 -L -t raw tcp://0.0.0.0:8000
EOF
chmod +x /usr/local/bin/sox-stream.sh
cat >/etc/systemd/system/sox-stream.service <<EOF
[Unit]
Description=SoX ALSA Loopback Streamer
After=aloop.service
Wants=aloop.service

[Service]
Type=simple
ExecStart=/usr/local/bin/sox-stream.sh
Restart=always
RestartSec=1
Nice=-5
IOSchedulingClass=best-effort
IOSchedulingPriority=0

[Install]
WantedBy=multi-user.target
EOF
systemctl enable aloop.service
systemctl enable sox-stream.service
systemctl start aloop.service
systemctl start sox-stream.service
