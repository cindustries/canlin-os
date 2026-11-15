# The boot gate of the CanLin images

Every image is verified under `qemu-system-i386 -cpu pentium2 -m 1024` before it meets real
hardware: the CPU model has no SSE and no PAE, so a binary that slips an instruction the
Pentium II does not have dies here instead of on the laptop.

## The harness

`test/boot-pentium2.sh` boots the built image (bzImage + rootfs.cpio.gz) and checks that the
boot reaches the init of this tree: the banner of `rcS`, the login on the console and the
shell prompt. The exit code is the verdict; a failing run prints the log of the boot.

```sh
test/boot-pentium2.sh                       # the image of the Buildroot tree beside this repo
test/boot-pentium2.sh /path/to/output/images # an image somewhere else
```

From the top of the tree: `make boot-test` runs the gate, `make qemu` boots the same image
with the console on the terminal (Ctrl-A x stops it).

The image directory can also be named in the environment (`CANLIN_OS_IMAGES`), the boot
budget in `CANLIN_BOOT_TIMEOUT` (180 s) and the budget for the login in
`CANLIN_LOGIN_TIMEOUT` (60 s).

## What it proves, and what it does not

It proves that the kernel starts, that it finds the initramfs, that the init of this tree
runs and that the console of the image is the serial line with a shell behind it.

It does not prove that the runtime runs: the image carries the runtime with card k3, and
until that package exists the boot is all this gate can show. It does not prove anything
about the real laptop either - the QEMU machine is not the hardware, the framebuffer of the
laptop is not the framebuffer of QEMU, and a boot under emulation is not a boot on a
Pentium II.
