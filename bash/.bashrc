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

export PATH="$PATH:$HOME/go/bin"
export BAT_THEME="Solarized (light)"
export LS_COLORS="$(vivid generate catppuccin-latte)"
export PINENTRY_USER_DATA="gnome3"

#alias vim="nvim"
alias ls="lsd"
alias ll="lsd -l"
alias pass="PINENTRY_USER_DATA=\"curses\" pass"

function cl () {
    cd $1
    ls
}

function fzfo() {
    output=$(fzf --reverse --walker-skip .password-store,.git,node_modules,target,.npm,.nvm,.yarn,.cache --bind 'ctrl-/:change-preview-window(down|hidden|)' --preview 'bat -n --color=always {}' </dev/tty);
    nohup xdg-open "${output}" > /dev/null &
}

eval "$(starship init bash)"
source /usr/share/nvm/init-nvm.sh

