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
# 3) Download Installation script and make it execuatble

```
wget https://raw.githubusercontent.com/kavyamali/qemuontermux-debian/main/installdebian_raw.sh
```

```
chmod +x installdebian_raw.sh
```

# 4) Launch the Installation Script:

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

# NOTE: All the scripts and commands below are meant to be run in ```su -``` mode.

# Setting up Internet:

Copy all the commands in ```scripts/setup/internet.sh``` and run them in the VM.

# Setting up the Audio:

Method 1) Using a FFMPEG stream through TCP routed from through ALSA (Recommended)

This method works on every device tested so far, and is the recommended as pulseaudio is broken on many devices after android updates.
It starts a TCP stream at port 8000(configurable in the config) at system level on boot, which is routed to ALSA using the loopback module.

Install:

```
wget https://raw.githubusercontent.com/kavyamali/qemuontermux-debian/82391d5a01775b92a130341ec155b668c308c758/scripts/audio/install/ffmpeg-tcp.sh
```
```
chmod +x ffmpeg-tcp.sh
```
```
./ffmpeg-tcp.sh
```

Launch:

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
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:8000 \
    -device virtio-net-device,netdev=net0
```

Once installed and setup, the stream can be connected via a client on the localhost. Apps like Simple Protocol Player work perfectly as a client. 

Uninstall:

```
wget https://raw.githubusercontent.com/kavyamali/qemuontermux-debian/82391d5a01775b92a130341ec155b668c308c758/scripts/audio/uninstall/ffmpeg-tcp-remove.sh
```
```
chmod +x ffmpeg-tcp-remove.sh
```
```
./ffmpeg-tcp-remove.sh
```

Method 2) Using a SOX stream through TCP routed from through ALSA (Works only for CPUs with good scheduling, i.e, Snapdragon SOCs. Mediatek does not work.)

As mentioned above, this method requires cpu with good scheduler, as alsa pipes may break due to low buffer on CPUs with improperly exposed schedulers/pipelines. Mediatek devices are not supported. Exynos/Google Tensor are untested.
This method takes much less storage space, and takes less installtation time. 

Install:

```
wget https://github.com/kavyamali/qemuontermux-debian/raw/82391d5a01775b92a130341ec155b668c308c758/scripts/audio/install/sox-tcp.sh
```
```
chmod +x sox-tcp.sh
```
```
./sox-tcp.sh
```
The launch command is same as above.
Uninstall:

```
wget https://raw.githubusercontent.com/kavyamali/qemuontermux-debian/82391d5a01775b92a130341ec155b668c308c758/scripts/audio/uninstall/sox-tcp-uninstall.sh
```
```
chmod +x sox-tcp-uninstall.sh
```
```
./sox-tcp-uninstall.sh
```

# Sources and referecnces:

Tianocore EDKII: https:https://github.com/tianocore/edk2

Simple Protocol Player:https://github.com/kaytat/SimpleProtocolPlayer

