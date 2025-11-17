su -
set -e
ip link set eth0 up
cat > /etc/systemd/network/20-eth0.network <<'EOF'
[Match]
Name=eth0

[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd --now
systemctl restart systemd-networkd
