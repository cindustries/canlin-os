# CanLin OS: a Buildroot external tree (BR2_EXTERNAL).
#
# The tree carries the targets of the CanLin images (see Config.in) and the
# packages that belong to them (package/<name>/). Buildroot itself is never
# modified; the tree only adds to it.
#
# The kernel fragment of a target is named in its defconfig
# (BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES), so nothing has to be wired here.

include $(sort $(wildcard $(BR2_EXTERNAL_CANLIN_OS_PATH)/package/*/*.mk))

# The CanLin runtime is a package of this tree (package/canlin/). It is not
# built yet: the runtime binary itself is still being written in the canlin
# repository (its card k167), and the package that carries it into the image
# is the canlin-os card k3.
