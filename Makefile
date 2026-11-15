# The CanLin OS tree is a Buildroot external tree: the build itself runs in the
# Buildroot checkout beside it, never in this directory. These targets are the
# conveniences around that build - the defconfig, the build, the boot gate and
# the interactive boot.

BUILDROOT ?= $(CURDIR)/../buildroot
IMAGES ?= $(BUILDROOT)/output/images
DEFCONFIG ?= qemu_pentium2_defconfig

.PHONY: defconfig build boot-test qemu

# The configuration of the Pentium II target, written into the Buildroot tree.
defconfig:
	$(MAKE) -C $(BUILDROOT) BR2_EXTERNAL=$(CURDIR) $(DEFCONFIG)_defconfig

# The image: kernel, initramfs, BusyBox.
build:
	$(MAKE) -C $(BUILDROOT) BR2_EXTERNAL=$(CURDIR)

# The gate: boot the image and check that it reaches a shell.
boot-test:
	test/boot-pentium2.sh $(IMAGES)

# The same image, the console on the terminal.
qemu:
	CANLIN_BOOT_INTERACTIVE=1 test/boot-pentium2.sh $(IMAGES)
