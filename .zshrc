if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# if [[ -f "/opt/homebrew/bin/brew" ]] then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
# fi

# tmux tmp
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  mkdir -p $HOME/.tmux/plugins/tpm
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
#zinit snippet OMZP::git
# zinit snippet OMZP::podman
#zinit snippet OMZP::z
zinit snippet OMZP::common-aliases
zinit snippet OMZP::cp
zinit snippet OMZP::rsync
#zinit snippet OMZP::
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
if [ -f /bin/apt-get ]; then
  zinit snippet OMZP::z
  zinit snippet OMZP::debian
elif [ -f /bin/pacman ]; then
  zinit snippet OMZP::archlinux
fi
[[ ! -f "${fpath[1]}/_podman" ]] || podman completion -f "${fpath[1]}/_podman" zsh
# Load completions
autoload -Uz compinit;compinit
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=7777
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt interactivecomments
# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
#Tilix
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi
# Shell integrations
eval "$(fzf --zsh)"
# eval "$(zoxide init --cmd cd zsh)"
if [ -f /bin/apt-get ]; then
  echo ''
elif [ -f /bin/pacman ]; then
  eval "$(zoxide init zsh)"
fi
export HISTORY_IGNORE="(*6789*|*password*|*secret*|*hash*|*authereg*|*password*)"
