# .bashrc -- read by every interactive shell, so keep it to shell behaviour:
# history, options, aliases, completion, prompt. Environment and PATH belong
# in .bash_profile, which runs once per login.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- History ---------------------------------------------------------------
# Default bash keeps 500 lines and *overwrites* ~/.bash_history on exit, so
# with several foot windows open the last one to close wins and the rest of
# the day's history is lost. histappend plus a per-prompt flush fixes that.
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups       # skip dupes and leading-space commands
HISTTIMEFORMAT='%F %T  '
HISTIGNORE='ls:ll:la:bg:fg:exit:clear:history:pwd'

shopt -s histappend                    # append instead of clobbering
shopt -s cmdhist                       # multi-line commands stay one entry
shopt -s histverify                    # !! expands for review, doesn't fire

# Flush after every command so a crashed terminal loses nothing. Note this
# only *writes*; it deliberately does not re-read, because pulling other
# terminals' commands into your up-arrow makes them unusable.
PROMPT_COMMAND='history -a'

# --- Shell options ---------------------------------------------------------
shopt -s checkwinsize                  # keep $LINES/$COLUMNS right after resize
shopt -s globstar                      # ** recurses
shopt -s autocd                        # `..` instead of `cd ..`
shopt -s cdspell dirspell              # fix minor typos in directory names
shopt -s no_empty_cmd_completion       # don't scan $PATH on a bare Tab
shopt -s checkjobs                     # warn before exiting with running jobs

# --- Colours ---------------------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b "$HOME/.dircolors" 2>/dev/null || dircolors -b)"
fi

alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# --- Listing (eza) ---------------------------------------------------------
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -l --group-directories-first --icons=auto --git --time-style=long-iso'
    alias la='eza -la --group-directories-first --icons=auto --git --time-style=long-iso'
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
    alias tree='eza --tree --group-directories-first --icons=auto'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh --color=auto --group-directories-first'
    alias la='ls -lha --color=auto --group-directories-first'
fi
alias l.='ls -d .*'

# --- Safety ----------------------------------------------------------------
# -I is the tolerable one: it prompts for recursive deletes and for more than
# three files, but stays quiet for `rm one-file`.
alias rm='rm -I --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'

# --- Void package management -----------------------------------------------
alias xi='sudo xbps-install -S'          # install (syncs first)
alias xu='sudo xbps-install -Suv'        # full system update
alias xr='sudo xbps-remove -R'           # remove + now-orphaned deps
alias xq='xbps-query -Rs'                # search remote
alias xl='xbps-query -l'                 # list installed
alias xf='xbps-query -Rf'                # files in a package
alias xo='xbps-query -o'                 # which package owns a file
alias xclean='sudo xbps-remove -Ooy'     # drop orphans and cached packages

# --- Sway / Wayland --------------------------------------------------------
alias swayreload='swaymsg reload'
alias swaytree='swaymsg -t get_tree | jq'
alias swayoutputs='swaymsg -t get_outputs | jq -r ".[] | \"\(.name)  \(.make) \(.model)  \(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh/1000)\""'
alias swaylog='less +G "$XDG_STATE_HOME/sway.log"'
alias c='wl-copy'
alias v='wl-paste'
# Region screenshot straight to the clipboard.
alias shot='grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied"'

# --- Misc ------------------------------------------------------------------
alias df='df -hT -x tmpfs -x devtmpfs'
alias du='du -h'
alias free='free -h'
alias path='printf "%s\n" ${PATH//:/ }'
alias ports='ss -tulpn'
alias lg='lazygit'

if command -v bat >/dev/null; then
    alias bathelp='bat --plain --language=help'
    # Syntax-highlighted man pages. /usr/bin/man is mandoc here, which marks
    # bold/underline with backspace-overstrike rather than ANSI SGR, so strip
    # it with col(1). (MANROFFOPT is a man-db/groff knob; mandoc ignores it.)
    export MANPAGER="sh -c 'col -bx | bat -p -l man'"
fi

# --- Functions -------------------------------------------------------------
# yazi wrapper: leaves the shell in whatever directory yazi exited from.
y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Extract any archive without remembering the flags.
extract() {
    [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
        *.tar.gz|*.tgz)   tar xzf "$1"   ;;
        *.tar.xz|*.txz)   tar xJf "$1"   ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.tar)            tar xf  "$1"   ;;
        *.bz2)            bunzip2 "$1"   ;;
        *.gz)             gunzip  "$1"   ;;
        *.xz)             unxz    "$1"   ;;
        *.zip)            unzip   "$1"   ;;
        *.7z)             7z x    "$1"   ;;
        *.rar)            unrar x "$1"   ;;
        *) echo "extract: don't know how to open '$1'" >&2; return 1 ;;
    esac
}


# --- fzf -------------------------------------------------------------------
if command -v fzf >/dev/null; then
    export FZF_DEFAULT_OPTS="
        --height=45% --layout=reverse --border=rounded --info=inline
        --bind=ctrl-/:toggle-preview,ctrl-u:preview-page-up,ctrl-d:preview-page-down
        --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"

    if command -v fd >/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type=f --hidden --follow --exclude=.git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type=d --hidden --follow --exclude=.git'
    fi

    command -v bat >/dev/null &&
        export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"
    command -v eza >/dev/null &&
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto --color=always {}'"

    # Ctrl-T file, Ctrl-R history, Alt-C cd
    [ -r /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash
    [ -r /usr/share/fzf/completion.bash ]   && . /usr/share/fzf/completion.bash
fi

# --- Prompt ----------------------------------------------------------------
# Kept cheap: one `git` call inside a repo, none outside. The title escape
# gives foot/ghostty a useful window name, which is what noctalia's window
# switcher shows; OSC 7 tells the terminal the cwd so a new window opens here.
__prompt_git() {
    local branch dirty
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    [ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ] && dirty='*'
    printf ' \001\033[0;33m\002(%s%s)\001\033[0m\002' "$branch" "$dirty"
}

__prompt() {
    local status=$?
    local reset='\[\033[0m\]' blue='\[\033[1;34m\]' green='\[\033[0;32m\]'
    local red='\[\033[1;31m\]' dim='\[\033[2m\]'
    local title='\[\033]0;\u@\h: \w\007\]'
    local osc7='\[\033]7;file://\h\w\033\\\]'
    local mark

    if [ "$status" -eq 0 ]; then mark="${green}\$${reset}"
    else mark="${red}${status}\$${reset}"; fi

    # root gets a red host so a stray sudo -i is obvious
    if [ "$EUID" -eq 0 ]; then
        PS1="${title}${osc7}${red}\u@\h${reset}${dim}:${reset}${blue}\w${reset}$(__prompt_git)\n${mark} "
    else
        PS1="${title}${osc7}${green}\u@\h${reset}${dim}:${reset}${blue}\w${reset}$(__prompt_git)\n${mark} "
    fi
}
PROMPT_COMMAND="__prompt; $PROMPT_COMMAND"

# --- zoxide ----------------------------------------------------------------
# Must come last: it prepends its own hook to PROMPT_COMMAND.
# `z foo` jumps to the best match, `zi foo` picks from an fzf list.
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
