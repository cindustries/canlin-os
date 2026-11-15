#!/bin/sh
# The boot gate of the Pentium II image (card k2).
#
# It boots the built image under qemu-system-i386 with the CPU model of the
# Pentium II and checks that the boot reaches the init of this tree: the
# banner of rcS, the login on the console and the shell prompt.
#
# Usage: test/boot-pentium2.sh [image-directory]
#
# The image directory holds bzImage and rootfs.cpio.gz; it defaults to the
# output of the Buildroot tree beside this repository. The exit code is the
# verdict: 0 means the image booted to a shell, anything else is the failure
# and the log of the boot is printed.
#
# The boot is not the runtime: the image carries the runtime with card k3.
# Until then the gate proves the kernel, the initramfs, the console and the
# init of this tree - and nothing more.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(dirname "$here")

images=${1:-${CANLIN_OS_IMAGES:-$repo/../buildroot/output/images}}
kernel=$images/bzImage
initrd=$images/rootfs.cpio.gz
[ -f "$initrd" ] || initrd=$images/rootfs.cpio
boot_timeout=${CANLIN_BOOT_TIMEOUT:-180}
login_timeout=${CANLIN_LOGIN_TIMEOUT:-60}
# The interactive mode hands the console to the terminal and checks nothing: it
# is the way to look at the boot by hand.
interactive=${CANLIN_BOOT_INTERACTIVE:-0}

fail() {
    printf 'boot-pentium2: %s\n' "$1" >&2
    exit 1
}

[ -f "$kernel" ] || fail "no kernel in $images (bzImage is missing - build the image first)"
[ -f "$initrd" ] || fail "no initramfs in $images (rootfs.cpio.gz is missing - build the image first)"
command -v qemu-system-i386 >/dev/null 2>&1 || fail "qemu-system-i386 is not on PATH"

if [ "$interactive" != "0" ]; then
    printf 'boot-pentium2: interactive - the console is yours, ^A x stops the machine\n'
    exec qemu-system-i386 -cpu pentium2 -m 1024 \
        -kernel "$kernel" -initrd "$initrd" \
        -append "console=ttyS0,115200 panic=1" \
        -netdev user,id=net0 -device e1000,netdev=net0 \
        -audiodev none,id=snd0 -device ac97,audiodev=snd0 \
        -nographic -no-reboot
fi

log=$(mktemp)
fifo=$(mktemp -u)
mkfifo "$fifo"
qemu_pid=

cleanup() {
    if [ -n "$qemu_pid" ]; then
        kill "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    exec 3>&- 2>/dev/null || true
    rm -f "$fifo" "$log"
}
trap cleanup EXIT INT TERM

# The serial line is the console of the image, so the keyboard of the host
# reaches the guest through the standard input of QEMU. The write end of the
# pipe is opened read-write, so it does not wait for a reader.
exec 3<>"$fifo"

printf 'boot-pentium2: gate: qemu-system-i386 -cpu pentium2 -m 1024 | images: %s\n' "$images"

start=$(date +%s)
qemu-system-i386 -cpu pentium2 -m 1024 \
    -kernel "$kernel" -initrd "$initrd" \
    -append "console=ttyS0,115200 panic=1" \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -audiodev none,id=snd0 -device ac97,audiodev=snd0 \
    -nographic -no-reboot <"$fifo" >"$log" 2>&1 &
qemu_pid=$!

# Wait for a marker: the text has to appear in the log of the boot.
wait_for() {
    needle=$1
    budget=$2
    waited=0
    while [ "$waited" -lt "$budget" ]; do
        if grep -q "$needle" "$log"; then
            return 0
        fi
        if ! kill -0 "$qemu_pid" 2>/dev/null; then
            return 1
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

show_log() {
    printf -- '--- log ---\n' >&2
    tail -40 "$log" >&2
}

if ! wait_for 'CanLin: the image is up' "$boot_timeout"; then
    printf 'boot-pentium2: the boot did not reach the init of the tree in %ss\n' "$boot_timeout" >&2
    show_log
    exit 1
fi
printf 'boot-pentium2: the init of the tree ran after %ss\n' "$(( $(date +%s) - start ))"

if ! wait_for 'CanLin: ready' "$boot_timeout"; then
    printf 'boot-pentium2: the init did not finish\n' >&2
    show_log
    exit 1
fi

# The getty asks for a keypress before it hands out the prompt, and login
# wants a name. Both come through the pipe. The Enter is sent again and
# again, because one that comes before the getty is lost.
prompt=0
login_sent=0
waited=0
while [ "$waited" -lt "$login_timeout" ]; do
    if grep -Eq '^[A-Za-z0-9_./~-]*[$#][ ]*$' "$log"; then
        prompt=1
        break
    fi
    if ! kill -0 "$qemu_pid" 2>/dev/null; then
        break
    fi
    if [ "$login_sent" -eq 0 ] && grep -q 'login:' "$log"; then
        printf 'root\n' >&3 2>/dev/null || true
        login_sent=1
    else
        printf '\n' >&3 2>/dev/null || true
    fi
    sleep 2
    waited=$((waited + 2))
done

if [ "$prompt" -ne 1 ]; then
    printf 'boot-pentium2: no shell prompt on the console\n' >&2
    show_log
    exit 1
fi

printf 'boot-pentium2: OK - the image booted to a shell after %ss\n' "$(( $(date +%s) - start ))"
printf 'boot-pentium2: note: the runtime is not in this image yet (card k3) - the gate proves the boot, not the runtime\n'
exit 0
