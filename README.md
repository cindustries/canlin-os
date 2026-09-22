# gnx-os

Buildroot external tree that turns the gnx runtime into a bootable image: Linux kernel,
musl, BusyBox, gnx, nothing else, running entirely from RAM. First target is a Pentium II
laptop (i686 without SSE, 686 kernel without PAE); an x86 tablet target follows. Every
image is verified under `qemu-system-i386 -cpu pentium2` before it meets real hardware.

Runtime and architecture: the `gnx` repo (skill `gnx-core`, hardlinked here).
