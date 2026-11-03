# canlin-os House Rules

The shared house rules come from skilletor — bundle `getty-house@getty`: engineering
discipline, the delegation lock, the publish gate, karr coordination. They load as
`.claude/rules/.local.*.md`; if they are missing, run `skilletor sync` and publish nothing
until they load. This file adds what is true only here, and wins where it differs.

## What this repo is

Buildroot external tree that turns the CanLin runtime into a bootable image. The image
contains what the runtime needs and nothing else — every added package is a question, not a
default. Read first: a target's kernel fragment and defconfig before adding an option;
upstream Buildroot's own package before writing a new one.

Success criterion: boots in QEMU to the runtime with framebuffer, input, network, audio.
"Built" is not "boots"; say which one you have.

## Agent team

| Task | Agent |
|---|---|
| Buildroot tree, packages, defconfigs, kernel fragments, boot media, QEMU harness | `canlin-os-worker` (default) |
| Route a ticket to canlin, libbee, p5-beepack or sunriser8 | `karr-coordinator` |
| Read-only research, audit, gap analysis | `canlin-os-worker` ("read-only, change nothing") |

Behavior-relevant = everything under `configs/`, `board/`, `package/`, `test/`, `Config.in`,
`external.mk`, the Makefile. README and prose docs are not.

canlin-os is part of the CanLin family: a runtime change is a ticket on the `canlin` board, a
library change a ticket on `libbee` — protocol: skill `canlin-coordination`.

## Release

Building and booting images in QEMU is fine anytime. Writing an image to a physical disk or
USB stick, or publishing an image, needs the maintainer's explicit go-ahead — a wrong `dd`
target erases a real disk.

## Deviations from the house rules

- **No release-manager.** The team has no release-manager agent: the dispatching main agent
  owns commits; the worker leaves a commit-ready tree plus a proposed subject and `Changes`
  entry.

## Hazards

- **Buildroot builds are heavy.** One full build takes gigabytes and every core; never run two
  in parallel on this machine, and never commit `output/` or `dl/`.
- **The host is not the target.** Everything is cross-compiled; a binary that runs here proves
  nothing. QEMU with `-cpu pentium2` is the minimum; the real laptops are the final word.

## Architecture — reference, don't restate

What the runtime needs from the image, the hardware floor and the targets are in skill
`canlin-core`; repo ownership in `canlin-coordination`.
