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

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/go/bin:$HOME/.local/bin"
export LS_COLORS="$(vivid generate catppuccin-mocha)"
export PINENTRY_USER_DATA="gnome3"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

#alias vim="nvim"
alias ls="lsd"
alias ll="lsd -l"
alias pass="PINENTRY_USER_DATA=\"curses\" pass"
alias mpv-yt="mpv --vo=kitty --vo-kitty-use-shm=yes --profile=sw-fast --really-quiet --ytdl-format=\"bestvideo[height<=?360][fps<=?30][vcodec!=?vp9]+bestaudio/best\""
alias ssh="TERM=xterm-256color kitten ssh"

function cs () {
    cd $1
    ls
}

function fzfo() {
    output=$(fzf --reverse --walker-skip .password-store,.git,node_modules,target,.npm,.nvm,.yarn,.cache --bind 'ctrl-/:change-preview-window(down|hidden|)' --preview 'bat -n --color=always {}' </dev/tty);
    nohup xdg-open "${output}" > /dev/null &
}

eval "$(starship init bash)"
source /usr/share/nvm/init-nvm.sh
