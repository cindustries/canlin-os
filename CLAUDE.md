# CLAUDE.md — gnx-os

Buildroot external tree producing the gnx images: Linux kernel, musl, BusyBox, the gnx
runtime, as an initramfs running from RAM. Targets: Pentium II laptop (i686, no SSE,
686 kernel without PAE), later an x86 tablet. No tree yet — the first tickets on the
karr board set it up.

Build and test: `make <target>_defconfig && make` (Buildroot beside the tree, never
committed); `make qemu` boots the result under `qemu-system-i386 -cpu pentium2 -m 1024`.

## Delegation

Delegate behavior-relevant files to the right agent instead of touching them yourself —
principle and lane are in `.claude/rules/gnx-os-rules.md`.

| Task | Agent |
|---|---|
| Buildroot tree, packages, defconfigs, kernel fragments, boot media, QEMU harness | `gnx-os-worker` (default) |
| Route a ticket to gnx, libbee, p5-beepack or sunriser8 | `karr-coordinator` |

The agents carry their skills via `briefing.skills` (see `.claude/agents/`); the main
agent delegates rather than loading them. Skills `gnx-core` and `gnx-coordination` are
owned by `~/dev/gnx` and hardlinked under `.claude/skills/`. Work is tracked on the
local `karr` board.
