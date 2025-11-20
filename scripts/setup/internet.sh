set -e
for IFACE in /sys/class/net/*; do
    IFACE=$(basename "$IFACE")
    [ "$IFACE" = "lo" ] && continue
    ip link set "$IFACE" up || true
done
cat > /etc/systemd/network/25-all.network <<EOF
[Match]
Name=*

[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd --now
systemctl restart systemd-networkd
