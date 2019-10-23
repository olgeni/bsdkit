q-history-search-backward()
{
    local cursor=$CURSOR
    zle .history-search-backward "$LBUFFER"
    CURSOR=$cursor
}

q-history-search-forward()
{
    local cursor=$CURSOR
    zle .history-search-forward "$LBUFFER"
    CURSOR=$cursor
}

zle -N q-history-search-backward
zle -N q-history-search-forward

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt append_history
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt interactive_comments
setopt notify
setopt promptsubst

unsetopt flowcontrol

if [ $(uname) != "CYGWIN_NT-10.0" ]; then
    setopt hist_fcntl_lock
fi

zstyle ':completion:*' menu select

bindkey -e

autoload -U zmv
autoload -U run-help

autoload run-help
autoload run-help-git
autoload run-help-openssl
autoload run-help-sudo
autoload run-help-svn

WORDCHARS=""

prompt="[%l:%n@%m %2~]%# "

bindkey "^N"      q-history-search-forward
bindkey "^P"      q-history-search-backward

bindkey '\e[A'    up-line-or-history
bindkey '\e[B'    down-line-or-history
bindkey '\e[C'    forward-char
bindkey '\e[D'    backward-char
bindkey '\e[H'    beginning-of-line
bindkey '\e[F'    end-of-line
bindkey '\e\e[C'  forward-word
bindkey '\e\e[D'  backward-word
bindkey '\eOC'    forward-word
bindkey '\eOD'    backward-word
bindkey "^U"      universal-argument

bindkey '\eOA'    up-line-or-history
bindkey '\eOB'    down-line-or-history
bindkey '\eOC'    forward-char
bindkey '\eOD'    backward-char
bindkey '\eOH'    beginning-of-line
bindkey '\eOF'    end-of-line
bindkey '\e\eOC'  forward-word
bindkey '\e\eOD'  backward-word

bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word

bindkey '\e[1~'   beginning-of-line
bindkey '\e[4~'   end-of-line

bindkey '\e[3~'   delete-char-or-list
bindkey '\e[E'    delete-char-or-list

if [[ $TERM = cons25 ]]; then
    bindkey '^?' delete-char-or-list
fi

if [[ $TERM = screen ]]; then
    bindkey '^?' backward-delete-char
fi

chpwd()
{
    [[ -t 1 ]] || return

    case ${TERM} in
        *xterm*)
            print -Pn "\e]2;%~\a"
            ;;
    esac
}

local _file

if [ -d ~/.zsh ]; then
    for _file in ~/.zsh/*.sh(N); do
        source ${_file}
    done
fi

if [ ${UID} != 0 -a -d ~/.zsh/completion ]; then
    if [ -d ~/.zsh/completion ]; then
        fpath=(~/.zsh/completion $fpath)
    fi
fi

autoload -Uz compinit

compinit

if which direnv >/dev/null 2>&1; then
    source <(direnv hook zsh)
fi

if which vim >/dev/null 2>&1; then
    export ALTERNATE_EDITOR=vim
    export EDITOR=vim
    export VISUAL=vim
fi

case $(uname) in
    Darwin)
	# PATH is taken care of in /etc/paths
        export PATH=$PATH:~/bin
        ;;
    FreeBSD)
        export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/bin:/usr/local/sbin:~/bin
        ;;
    *)
esac

# rvm
export PATH="$PATH:$HOME/.rvm/bin"

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

export LANG=en_US.UTF-8
export CLICOLOR=yes
export GPG_TTY=$(tty)

if [ -n "${INSIDE_EMACS}" ]; then
    export ALTERNATE_EDITOR=emacsclient
    export EDITOR=emacsclient
    export VISUAL=emacsclient
    unset zle_bracketed_paste
    bindkey -r "^[x"
fi

cdpath=()

if [ -e ${HOME}/.zshrc.local ]; then
    source ${HOME}/.zshrc.local
fi
