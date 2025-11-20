#!/bin/bash
set -e
apt install ffmpeg alsa-utils -y
cat >/etc/systemd/system/aloop.service <<EOF
[Unit]
Description=ALSA Loopeback Device (snd-aloop)
DefaultDependencies=no
Before=sound.target

[Service]
Type=oneshot
ExecStart=/sbin/modprobe snd-aloop

[Install]
WantedBy=sound.target
EOF
cat >/etc/asound.conf <<EOF
pcm.loop_playback {
    type plug
    slave {
        pcm "hw:Loopback,0,0"
        channels 2
        rate 48000
        format S16_LE
    }
}

pcm.loop_capture {
    type plug
    slave {
        pcm "hw:Loopback,1,0"
        channels 2
        rate 48000
        format S16_LE
    }
}
EOF
###CONFIGURE YOUR PORT BELOW
cat >/usr/local/bin/audio-stream.sh <<EOF
#!/bin/bash
set -e
exec ffmpeg -nostdin \
    -f alsa -i loop_capture \
    -ac 2 -ar 48000 \
    -f s16le tcp://0.0.0.0:8000?listen=1 \
    >>/root/ffmpeg.log 2>&1
EOF
chmod +x /usr/local/bin/audio-stream.sh
cat >/etc/systemd/system/audio-stream.service <<EOF
[Unit]
Description=FFmpeg ALSA Loopback Streamer
After=aloop.service
After=sound.target
Wants=aloop.service

[Service]
Type=simple
ExecStart=/usr/local/bin/audio-stream.sh
Restart=always
RestartSec=1
Nice=-5
ProtectSystem=no
ProtectHome=no

[Install]
WantedBy=multi-user.target
EOF
systemctl enable aloop.service
systemctl enable audio-stream.service
systemctl start aloop.service
systemctl start audio-stream.service
alsactl init
