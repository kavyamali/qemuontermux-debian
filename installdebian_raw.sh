pkg update -y
pkg upgrade -y
pkg install -y qemu-system-aarch64 openssh wget
wget https://github.com/kavyamali/qemuontermux-debian/releases/download/qcow2/debian.qcow2.part.aa
wget https://github.com/kavyamali/qemuontermux-debian/releases/download/qcow2/debian.qcow2.part.ab
wget https://github.com/kavyamali/qemuontermux-debian/releases/download/qcow2/debian.qcow2.part.ac
cat debian.qcow2.part.* > debian.qcow2
rm debian.qcow2.part.*
