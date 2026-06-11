# Debian package administration cheatsheet

A power-user reference for `apt`, `apt-cache`, `dpkg`, and friends.

---

## Searching packages

| Command | Description |
|---|---|
| `apt search <term>` | Full-text search in package names and descriptions |
| `apt-cache search <term>` | Fast regex search across all package metadata |
| `apt-cache show <pkg>` | Full metadata: version, deps, description, size |
| `apt-cache showpkg <pkg>` | Forward/reverse dependency graph |
| `apt list --installed \| grep <term>` | Search only installed packages |
| `apt-file search <file>` | Find which package owns a specific file¹ |
| `apt-file update` | Update apt-file index (run after `apt update`)¹ |

¹ Requires `apt install apt-file`

---

## Installing packages

| Command | Description |
|---|---|
| `apt install <pkg>` | Install package and its dependencies |
| `apt install <pkg>=<version>` | Pin and install a specific version |
| `apt install --no-install-recommends <pkg>` | Skip recommended (non-essential) packages |
| `apt install -f` | Fix broken dependencies — installs missing deps |
| `dpkg -i package.deb` | Install a local .deb file directly |
| `apt install ./package.deb` | Install local .deb and resolve deps via apt |
| `apt reinstall <pkg>` | Force reinstall (useful to restore corrupted files) |

---

## Removing packages

| Command | Description |
|---|---|
| `apt remove <pkg>` | Remove package, keep config files |
| `apt purge <pkg>` | Remove package **and** all config files |
| `apt autoremove` | Remove orphaned packages no longer needed |
| `apt autoremove --purge` | Autoremove and purge their config files |
| `dpkg --remove <pkg>` | Remove via dpkg, preserving configs |
| `dpkg --purge <pkg>` | Purge via dpkg including configs |

---

## Upgrading the system

| Command | Description |
|---|---|
| `apt update` | Refresh package index from all configured repos |
| `apt upgrade` | Upgrade all upgradable packages (safe — no removals) |
| `apt full-upgrade` | Upgrade with allowance for package removal to resolve conflicts |
| `apt upgrade <pkg>` | Upgrade only a specific package |
| `apt list --upgradable` | Show all packages with available upgrades |
| `apt-mark hold <pkg>` | Pin a package, preventing it from being upgraded |
| `apt-mark unhold <pkg>` | Release a held package back to normal upgrades |
| `apt-mark showhold` | List all held (pinned) packages |

---

## Inspecting packages & files

| Command | Description |
|---|---|
| `dpkg -l` | List all installed packages with version and status |
| `dpkg -l <pkg>` | Check if a specific package is installed and its version |
| `dpkg -L <pkg>` | List all files installed by a package |
| `dpkg -S /path/to/file` | Find which package owns an installed file |
| `dpkg -c package.deb` | List contents of a .deb file without installing |
| `dpkg -I package.deb` | Show metadata/info from a .deb file |
| `apt-cache depends <pkg>` | Show direct dependencies of a package |
| `apt-cache rdepends <pkg>` | Show reverse deps — what depends on this package |
| `apt-cache policy <pkg>` | Show installed vs available version and pinning priority |

---

## Managing repositories

| Command | Description |
|---|---|
| `cat /etc/apt/sources.list` | Main repo list (legacy format) |
| `ls /etc/apt/sources.list.d/` | Per-repo config files (modern drop-in directory) |
| `add-apt-repository ppa:<user>/<ppa>` | Add a PPA² |
| `add-apt-repository --remove ppa:<user>/<ppa>` | Remove a PPA |
| `apt-key list` | List trusted GPG keys (legacy keyring) |
| `gpg --dearmor -o /etc/apt/keyrings/<name>.gpg` | Import a repo GPG key (modern keyrings/ approach) |
| `apt update 2>&1 \| grep -i error` | Refresh index and surface any repo errors |

² Requires `apt install software-properties-common`

---

## dpkg low-level operations

| Command | Description |
|---|---|
| `dpkg --get-selections` | Dump all package selections (install/hold/deinstall) |
| `dpkg --set-selections < file` | Restore package selections from a saved file |
| `dpkg --configure -a` | Finish configuring any partially installed packages |
| `dpkg --audit` | Find packages in inconsistent/broken state |
| `dpkg-query -W -f='${Package} ${Version}\n'` | Custom format list of installed packages + versions |
| `dpkg-reconfigure <pkg>` | Re-run the post-install configuration wizard |

---

## Cache, logs & power-user extras

| Command | Description |
|---|---|
| `apt clean` | Delete all cached .deb files in `/var/cache/apt/archives/` |
| `apt autoclean` | Delete only outdated cached .debs (keeps current versions) |
| `cat /var/log/dpkg.log \| grep 'install '` | Audit log of every package install event |
| `cat /var/log/apt/history.log` | Human-readable apt command history |
| `apt download <pkg>` | Download .deb to current dir without installing |
| `dpkg-deb --extract pkg.deb ./dir` | Extract .deb contents to a directory |
| `debconf-show <pkg>` | View current debconf settings for a package |
| `apt-get -s install <pkg>` | Dry-run: simulate install without making changes |

---

## Tips

- **`apt-cache policy <pkg>`** is underrated — it shows exactly why a package is at a certain version (pinning, repo priority, holds), invaluable when upgrades misbehave.
- **`apt-mark hold`** is the clean way to pin packages. Avoid editing `/etc/apt/preferences` manually unless you need complex multi-repo pinning rules.
- **`dpkg --configure -a`** is your first stop after an interrupted install or power loss mid-upgrade — it finishes half-configured packages before apt will cooperate again.
- **`apt-get -s`** (simulate) is worth running before any risky upgrade to preview exactly what will be installed, upgraded, or removed.
