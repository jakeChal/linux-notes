# ~/.zshrc — power-user setup
# See setup.md in this repo for installation instructions.

# --- p10k instant prompt (must stay near the top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf                   # enables fzf keybindings automatically
  z                     # jump to frecent directories (built-in to OMZ)
  sudo                  # press ESC twice to prepend sudo to last command
  copypath              # copy current path to clipboard
  dirhistory            # ALT+LEFT/RIGHT to navigate directory history
)

source $ZSH/oh-my-zsh.sh

# --- fzf: use fd + bat as backends ---
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"
export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# --- Modern CLI replacements ---
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons -L 2'

# --- tmux + Yakuake workflow ---
alias ta='tmux attach || tmux new -s main'

# --- p10k / tmux instant-prompt quiet mode ---
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- zoxide (must be last) ---
eval "$(zoxide init zsh)"

# --- p10k config ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
