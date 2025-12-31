#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ $DISPLAY ]] && shopt -s checkwinsize


PS1='[\u@\h \W]\$ '

case ${TERM} in
  Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
    PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')

    ;;
  screen*)
    PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
    ;;
esac

# SSH agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# Bash completion
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Configure color scheme and theme
configure_color_scheme() {
  export COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'\"")
  
  if [[ $COLOR_SCHEME == 'prefer-light' ]] || [[ $COLOR_SCHEME == 'default' ]]; then
    export THEME="catppuccin-latte"
  else
    export THEME="catppuccin-frappe"
  fi
}
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzfrc"
export PATH="$PATH:$HOME/go/bin:$HOME/.local/bin:$HOME/.scripts"

# Initialize color scheme
configure_color_scheme

export PINENTRY_USER_DATA="gnome3"
export EDITOR=nvim
export YAZI_CONFIG_HOME=~/dotfiles/yazi
export MANPAGER="nvim +Man!"

#alias vim="nvim"

alias pass="PINENTRY_USER_DATA=\"curses\" pass"
alias mpv-yt-cli="mpv --vo=kitty --vo-kitty-use-shm=yes --profile=sw-fast --really-quiet --ytdl-format=\"bestvideo[height<=?360][fps<=?30][vcodec!=?vp9]+bestaudio/best\""
alias mpv-yt="mpv --ytdl-format=\"bestvideo[height<=?800][fps<=?30][vcodec!=?vp9]+bestaudio/best\""
alias batc="bat -l conf -p"
alias reload="source ~/.bashrc && echo 'Reloaded!'"
alias ls="lsd"
alias ll="ls -l"
alias cat="bat"

# If on kitty and not using ZelliJ use ssh kitten
if [[ "$TERM" == "xterm-kitty" && -z "$ZELLIJ" ]]; then
  alias ssh="TERM=xterm-256color kitten ssh"

  # Regular SSH command function without kitty kitten
  function cssh() {
      TERM=xterm-256color command ssh "$@"
  }
else
  alias ssh="TERM=xterm-256color ssh"
fi

cs() {
    cd $1
    ls
}

yayf() {
    yay -Slq | command fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S
}

# Load environment variables from .env file
function loadenv() {
  local env_file="${1:-.env}"
  
  if [[ -f "$env_file" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip empty lines and comments
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      
      # Remove any comments from the end of the line
      line="${line%%#*}"
      
      # Trim whitespace
      line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      
      # Export the variable
      export "${line?}"
    done < "$env_file"
  else
    echo "Error: $env_file file not found"
    return 1
  fi
}

# Auto-load .env file in the current directory if it exists
if [[ -f ".env" ]]; then
  loadenv
fi

eval "$(starship init bash)"
eval "$(fzf --bash)"
eval "$(zoxide init bash)"
source /usr/share/nvm/init-nvm.sh
