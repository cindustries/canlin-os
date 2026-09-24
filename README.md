# canlin-os

*CanLin — Linux that can. Straight out of a can.*

Buildroot external tree that turns the CanLin runtime into a bootable image: Linux kernel,
musl, BusyBox, CanLin, nothing else, running entirely from RAM. First target is a Pentium II
laptop (i686 without SSE, 686 kernel without PAE); an x86 tablet target follows. Every
image is verified under `qemu-system-i386 -cpu pentium2` before it meets real hardware.

Runtime and architecture: the `canlin` repo (skill `canlin-core`, hardlinked here).
