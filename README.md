# Preinstalled Debian 13 on Termux QEMU
A Debain 13 netinstall build preinstalled with termux OVMF TianoCore EFI firmware. The build has full ```systemd``` integration and comes preinstalled with SSH and Basic System Utilities.


# Installation Steps (Android 10+)

# 1) Setup termux and update packages:


```
termux-change-repo
```
Note: For termux-change-repo, choose 'All mirrors'
```
pkg update -y && pkg upgrade -y
```
```
termu-setup-storage
```

# 2) Install wget

```
pkg install wget -y
```
# 3) Download Installtion script and make it execuatble

```
wget https://raw.githubusercontent.com/kavyamali/qemuontermux-debian/main/installdebian_raw.sh
```

```
chmod +x installdebian_raw.sh
```

# 4) Launch the Installtion Script:

```
./installdebian_raw.sh
```
# 5) Use QEMU to launch the VM:

```
qemu-system-aarch64 \
    -M virt -cpu max \
    -m 2048 -smp 4 \
    -nographic \
    -boot c \
    -device virtio-gpu-pci \
    -device usb-ehci,id=usb_ctrl \
    -device usb-kbd,bus=usb_ctrl.0 \
    -device usb-tablet,bus=usb_ctrl.0 \
    -drive if=virtio,format=qcow2,file=debian.qcow2 \
    -bios QEMU_EFI.fd \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net-device,netdev=net0
```
> -m attribute can be changed to increase/decrease memory.
# 6) Login

```
Username: test
Password: test
```
> TO USE ROOT PRIVILIDGE, USE ```su -```

# 7) Setting up VNC

To use VNC with QEMU, remove the ```-nographic``` flag and add the vnc port. For example:

```
qemu-system-aarch64 \
    -M virt -cpu max \
    -m 4096 -smp 4 \
    -boot c \
    -vnc 127.0.0.1:1 \
    -device virtio-gpu-pci \
    -device usb-ehci,id=usb_ctrl \
    -device usb-kbd,bus=usb_ctrl.0 \
    -device usb-tablet,bus=usb_ctrl.0 \
    -drive if=virtio,format=qcow2,file=debian.qcow2 \
    -bios QEMU_EFI.fd \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net-device,netdev=net0

```
This will launch a Debian Console interface inside ```vncviewer```
The base installation and setup is now complete.

# Setting up SSH:

This installtion comes with SSH preinstalled. To start SSH, use the following commands in the VM:

Grant root privilidges:

```
su -

```

```
systemctl enable ssh
systemctl start ssh
```
Now, check the status:

```
systemctl status ssh
```
The status should be 
> ACTIVE

Now, check the SSH port. 

```grep Port /etc/ssh/sshd_config ```

The port should be 22 by default.
The QEMU hostfwd launch command must be modified to forward the port to host (termux):

```hostfwd=tcp::2222-:xxxx```
Where 'xxxx' is the port.
The user only needs to change xxxx if they change the port inside the VM.

The ssh can then be connected from the host, by using the command: 

```ssh test@127.0.0.1 -p 2222```

# SOURCES:

Tianocore EDKII: https://github.com/tianocore/edk2

