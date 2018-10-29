#!/bin/bash


iso() {
  # qemu-system-x86_64 -boot d -cdrom ~/Downloads/super_grub2_disk_hybrid_2.02s9.iso -m 512
  
  # Net ?
  # -net nic -net user,hostfwd=tcp::5555-:22
  
  # Test bootable usb
  # qemu-system-x86_64 -enable-kvm -localtime -m 2G -vga std -drive file=<device>,readonly,cache=none,format=raw,if=virtio

  
  MEM=${MEM:-1024}
  
  qemu-system-x86_64 -boot d -m ${MEM} -cdrom $@
}

"$@"
