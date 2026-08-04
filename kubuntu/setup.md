# Kubuntu 26.04 terminal environment bringup

Power-user terminal setup: Yakuake (drop-down, F12) + tmux (persistent sessions) +
Zsh + Oh My Zsh + Powerlevel10k + fzf + modern CLI tools.

Config files referenced below live in `configs/` in this repo and are symlinked
into place by `install.sh`.


---

## Install config files

Run the install script, which symlinks everything from `configs/` into `$HOME`:

```bash
./install.sh
```

This links:

| Repo file | Target |
|---|---|
| `configs/.zshrc` | `~/.zshrc` |
| `configs/.tmux.conf` | `~/.tmux.conf` |


Reload:

```bash
source ~/.zshrc
```

---

## 10. Quick reference — what's installed

| Tool | Purpose |
|---|---|
| Yakuake | F12 drop-down terminal (Konsole-based) |
| tmux | Persistent sessions, splits, detach/reattach |
| Zsh + Oh My Zsh | Shell + plugin/theme framework |
| Powerlevel10k | Prompt theme |
| zsh-autosuggestions | History-based ghost suggestions |
| zsh-syntax-highlighting | Live command validity coloring |
| fzf | Fuzzy finder (CTRL+R / CTRL+T / ALT+C) |
| fd | Fast `find`, used as fzf backend |
| bat | `cat` with syntax highlighting, fzf preview |
| eza | Modern `ls` with icons/git status |
| zoxide | Frecency-based `cd` (`z <fragment>`) |
| tldr | Practical command examples |

---

## Verification checklist

```bash
echo $SHELL              # /usr/bin/zsh
which fd bat eza zoxide fzf tmux yakuake
p10k configure           # only if prompt looks wrong

<F12>                    # should toggle Yakuake

tmux new -s test         # confirm tmux config loads without errors
<Ctrl+a> + d             # detach from tmux session
ta                       # attach to existing session. If not existing, create one called "main"
```

