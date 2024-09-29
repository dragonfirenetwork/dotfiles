# Paths
PATH="$HOME/.composer/vendor/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# History setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
bindkey "^[[A" history-search-backward # Uparrow
bindkey "^[[B" history-search-forward # Downarrow

# Zoxide
alias cd="z"
eval "$(zoxide init zsh)"

# Tmux
alias open-work="tmux new-session -s \"work\" -c \"$HOME/Work\""
alias open-projects="tmux new-session -s \"projects\" -c \"$HOME/Projects\""

# Initialize Starship prompt
eval "$(starship init zsh)"