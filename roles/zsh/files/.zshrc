# {{ ansible_managed }}

# Set system PATH just in case
export PATH="/usr/local/bin:$PATH"

if [[ -f /opt/homebrew/bin/brew ]]; then
    # Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ## Activate syntax highlighting
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ## Activate autosuggestions
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# OS convience aliases
if [[ -f /opt/homebrew/bin/brew ]]; then
    alias update='brew update && brew upgrade && brew cleanup'
else
    alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
fi

# History setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
bindkey "^[[A" history-search-backward # Up arrow
bindkey "^[[B" history-search-forward # Down arrow