# Snap Packaging Cheatsheet

## 1. Architecture — filesystems & lifecycle

A snap build runs inside a managed build instance (LXD or Multipass). Everything lives under
`/root` inside that instance:

```
/root/parts/<partname>/src/       ← pull:  raw fetched source, untouched
/root/parts/<partname>/build/     ← build: build actually happens here
/root/parts/<partname>/install/   ← stage: per-part build output
/root/stage/                      ← stage: all parts' install/ merged together
/root/prime/                      ← prime: final tree — this becomes the .snap
/root/project/                    ← your host checkout, bind-mounted (snapcraft.yaml, patches/)
```

**Lifecycle steps, in order** — each step only re-runs what's needed unless forced:

| Step | What happens | Env var pointing at its output |
|---|---|---|
| `pull` | Fetch source (git clone, tarball download, pip download, etc.) | `$CRAFT_PART_SRC` |
| `build` | Compile/build within the part | `$CRAFT_PART_BUILD` |
| `stage` | Copy build output into shared `stage/`, catching per-part collisions | `$CRAFT_STAGE` |
| `prime` | Copy stage output into `prime/`, applying final filtering | `$CRAFT_PRIME` |
| `pack` | Squash `prime/` into a `.snap` file | — |

`override-<step>` in `snapcraft.yaml` lets you inject custom shell commands at any step; call
`craftctl default` inside it to still run the step's normal behavior before/after your additions.

**Confinement levels** (`confinement:` in `snapcraft.yaml`):
- `strict` — full sandboxing, only declared `plugs`/`slots` allowed. Required for Snap Store `stable`.
- `classic` — no sandboxing, full system access (used by things like `snapcraft` itself).
- `devmode` — sandboxing disabled but logged; for development only, can't be released to `stable`.

---

## 2. Core commands

### Building
```bash
snapcraft                       # full build: pull → build → stage → prime → pack
snapcraft pull                  # run only through the pull step
snapcraft build                 # run only through the build step
snapcraft stage                 # run only through the stage step
snapcraft prime                 # run only through the prime step
snapcraft pack                  # pack an already-primed tree into a .snap
snapcraft clean                 # wipe all lifecycle state — forces a full rebuild
snapcraft clean <partname>      # wipe state for just one part
```

### Installing & running locally
```bash
sudo snap install --dangerous ./mysnap_1.0_amd64.snap   # install unsigned local build
sudo snap remove mysnap                                  # uninstall
snap list                                                 # see installed snaps + revisions
mysnap.command-name                                       # run an app defined in snapcraft.yaml
```

### Inspecting a snap
```bash
snap info ./mysnap_1.0_amd64.snap    # metadata from a local file
snap info mysnap                      # metadata from the Store
unsquashfs -l ./mysnap_1.0_amd64.snap # list files inside without installing
```

---

## 3. Debugging during packaging

### Get a shell mid-build
```bash
snapcraft <step> --shell        # drop into a shell instead of running that step
snapcraft <step> --shell-after  # run the step, THEN drop into a shell
snapcraft --debug               # on any command: auto-shell into the build instance on failure
```
The very first thing to run once you're in any of these shells:
```bash
ls -la /root
pwd
```
Don't assume paths from a previous session — layouts/versions can differ between builds.

### Finding files without guessing paths
```bash
find /root/prime -iname '<filename>' 2>/dev/null
find /root/prime /root/stage /root/parts -path '*/site-packages/<pkg>/<file>' 2>/dev/null
```

### Logs
```bash
snapcraft --verbosity=debug     # much more detailed build output
cat ~/.local/state/snapcraft/log/snapcraft-*.log   # full log of the most recent run
```

### Common failure classes seen in this workflow

| Symptom | Likely cause | Fix |
|---|---|---|
| `PermissionError: /run/user/<uid>` | No real login session (e.g. `lxc exec` bypasses PAM/systemd-logind) | `export XDG_RUNTIME_DIR=~/.xdg-runtime; mkdir -p $XDG_RUNTIME_DIR; chmod 700 $XDG_RUNTIME_DIR` — or use `lxc exec ... -- su - <user>` / SSH instead of raw `lxc exec` |
| `cannot pack: missing files: path "bin/<x>" does not exist` | `apps:` declares a command that the underlying pip package no longer ships (upstream dropped a console-script entry point) | Check with `find /root/prime/bin`; if genuinely gone, remove that `apps:` entry from `snapcraft.yaml` |
| Lint warnings (`title`, `contact`, `license`, `issues`, `source-code`, `website` missing) | Optional metadata fields left empty | Cosmetic only — safe to ignore for local dev builds; fill in before a Store submission |
| Patch silently doesn't apply | Wrong path in the patch's `---`/`+++` headers, or wrong `-d` target for `patch` | Re-discover the real install path with `find` (don't hardcode a Python version); test with `patch -p1 --dry-run -d <dir> < patch-file` before wiring into `override-prime` |
| `snapcraft shell` → "no such command" | Not a real subcommand in current `craft-application`-based snapcraft | Use `snapcraft <step> --shell` / `--shell-after` instead |
| Build looks stale / patch changes not reflected | Cached lifecycle state from a prior build | `snapcraft clean` before rebuilding |

---

## 4. Publishing to the Snap Store

### One-time setup
```bash
sudo snap install snapcraft --classic   # if not already installed
snapcraft login                          # authenticate with your Ubuntu One / Store account
snapcraft register <snap-name>           # claim the name (must be globally unique on the Store)
```

### Upload & release
```bash
snapcraft upload ./mysnap_1.0_amd64.snap
```
This uploads and returns a **revision number**. Uploading alone does not make it publicly
installable — you must explicitly release it to a channel:
```bash
snapcraft release <snap-name> <revision> <channel>
# e.g.:
snapcraft release mysnap 7 edge
```
Or upload-and-release in one step:
```bash
snapcraft upload ./mysnap_1.0_amd64.snap --release=edge
```

### Channels
Four risk levels, ordered least → most stable:
```
edge → beta → candidate → stable
```
Users install a specific channel with:
```bash
sudo snap install mysnap --channel=edge
sudo snap install mysnap --edge          # shorthand
```
Channels can also be combined with **tracks** (for maintaining parallel release lines, e.g. major
versions): `<track>/<risk>`, such as `2.0/stable`.

### Checking status
```bash
snapcraft status <snap-name>          # what's released where, per architecture/channel
snapcraft list-revisions <snap-name>  # full revision history
snapcraft revisions <snap-name>       # alias of the above on newer versions
```

### Closing a channel (unpublish from it, keep other channels intact)
```bash
snapcraft close <snap-name> <channel>
```

### Withdrawing entirely
```bash
snapcraft revoke <snap-name>   # only if you need to fully pull a snap — rare, talk to the Store team first
```

---

## Quick reference — typical local dev loop
```bash
# edit snapcraft.yaml / patches
snapcraft clean
snapcraft pack
sudo snap install --dangerous ./mysnap_*.snap
mysnap.command-name --test-the-thing
# repeat
```
