# ░       ░░░        ░░        ░░░      ░░░  ░░░░  ░░  ░░░░░░░░        ░░░      ░░
# ▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒
# ▓  ▓▓▓▓  ▓▓      ▓▓▓▓      ▓▓▓▓  ▓▓▓▓  ▓▓  ▓▓▓▓  ▓▓  ▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓      ▓▓
# █  ████  ██  ████████  ████████        ██  ████  ██  ███████████  ███████████  █
# █       ███        ██  ████████  ████  ███      ███        █████  ██████      ██

# If not running interactively, don't do anything
# NOTE: This safety check basically prevents programs and scripts from sourcing this file
# since they shouldn't have any business sourcing it. It's a defensive check to prevent bugs
# and recommended for this to always be present.
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# NOTE: You may want to enable or disable this depending on if this is
# on a server environment (for example if you use a lot of tmux sessions,
# you may not want all sessions to combine into one history file)
# Append to the history file, don't overwrite it:
#shopt -s histappend

# NOTE: The defaults for this are 500/500
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# NOTE: This is mostly defensive, if this wasn't here then there's not a lot
# of things affected. But doesn't hurt to have it.
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#! Ive never used chroot but this is here for reference
# Set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# NOTE: This may be redundant but it's a defensive check, in case we're
# in some minimal environment that didn't set up the bash competions already.
# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# ░  ░░░░  ░░  ░░░░  ░░░░░░░░        ░░   ░░░  ░░  ░░░░  ░
# ▒   ▒▒   ▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒
# ▓        ▓▓▓▓    ▓▓▓▓▓▓▓▓▓▓      ▓▓▓▓  ▓  ▓  ▓▓▓  ▓▓  ▓▓
# █  █  █  █████  ███████████  ████████  ██    ████    ███
# █  ████  █████  ███████████        ██  ███   █████  ████


# This sets the prompt to be color if we find color or 256 in TERM.
# NOTE: This block replaced a bunch of unnecessary checks in the default that provided
# compatibility with old hardware. I tend to use nice new terminals.
if [[ $TERM == *"color"* ]] || [[ $TERM == *"256"* ]]; then
    PS1="\$(date '+%H:%M:%S') \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
else
    PS1="\$(date '+%H:%M:%S') \u@\h:\w\$ "
fi

# NOTE: This updates the terminal tab title! It is important to have.
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ┌───────────────────────┐
# │       ENV Vars        │
# └───────────────────────┘

# These are locality settings. They ensure the terminal uses American English
# style for formatting, dates, etc. C.UTF-8 (basic POSIX) is often recommended
# instead of en_US.UTF-8 for containerized environments. In a normal desktop
# environment these are usuallly set by the OS and not needed here.
# export LANG=en_US.UTF-8
# export LC_ALL=C.UTF-8

# Poertry by default creates virtual environments in a special secret cache location.
# This makes it place them in the project folder. (I prefer for my .venv folders to always
# be in the project folder to have more control over them.)
export POETRY_VIRTUALENVS_IN_PROJECT=true

export mygithub="https://github.com/edward-jazzhands"

# ┌───────────────────────┐
# │      Git Config       │
# └───────────────────────┘

# Sets my global git ignore preferences:
git config --global core.excludesfile ~/.gitignore_global

# Sets gopass as the default git credential helper (Enable if installed):
# git config --global credential.helper gopass

# ┌───────────────────────┐
# │        Aliases        │
# └───────────────────────┘

# Apps
alias bat="batcat"
alias gcm="git-credential-manager"

# Lazy shortcuts
alias cl="clear"
alias resource="source ~/.bashrc"
alias bashrc="nano ~/.bashrc"
alias activate="source .venv/bin/activate"


# enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls="ls -lFa --color=auto"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    echo "WARNING: dircolors not found - you won't have color output.'"
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
#! NOTE: I have never used this before. It's just copied from the default .bashrc.
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'




# ░        ░░  ░░░░  ░░   ░░░  ░░░      ░░░        ░░        ░░░      ░░░   ░░░  ░░░      ░░
# ▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒▒▒▒
# ▓      ▓▓▓▓  ▓▓▓▓  ▓▓  ▓  ▓  ▓▓  ▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓  ▓▓  ▓  ▓  ▓▓▓      ▓▓
# █  ████████  ████  ██  ██    ██  ████  █████  ████████  █████  ████  ██  ██    ████████  █
# █  █████████      ███  ███   ███      ██████  █████        ███      ███  ███   ███      ██


# Prints a color gradient to test truecolor support
colortest() {
  awk 'BEGIN{
      s=" "; s=s s s s s s s s;
      for (colnum = 0; colnum<77; colnum++) {
          r = 255-(colnum*255/76);
          g = (colnum*510/76);
          b = (colnum*255/76);
          if (g>255) g = 510 - g;
          printf "\033[48;2;%d;%d;%dm%s\033[0m", r,g,b,substr(s,colnum%8+1,1);
      }
      printf "\n";
  }'
}


# ┌───────────────────────┐
# │    FZF and Ripgrep    │
# └───────────────────────┘

# fuzzy cd
fcd() {
  local dir
  dir=$(find . -type d -not -path '*/\.*' | fzf) && cd "$dir"
}

# fuzzy shell history
fsh() {
  eval "$(history | fzf | sed 's/ *[0-9]* *//')"
}

# search by file name
rgf() {
  rg --files --iglob "*$1*"
}



# ░░      ░░░       ░░░       ░░░░      ░░░░░░░░░        ░░   ░░░  ░░  ░░░░  ░░░      ░░
# ▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒
# ▓  ▓▓▓▓  ▓▓       ▓▓▓       ▓▓▓▓      ▓▓▓▓▓▓▓▓▓      ▓▓▓▓  ▓  ▓  ▓▓▓  ▓▓  ▓▓▓▓      ▓▓
# █        ██  ████████  ██████████████  ████████  ████████  ██    ████    ██████████  █
# █  ████  ██  ████████  █████████      █████████        ██  ███   █████  ██████      ██

# NOTE: If any of these apps are not installed, it'll just show an error message
# and continue on, which is fine. Comment out those lines or install the apps
# to stop seeing the error.

# Rust + Cargo
. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Zoxide
eval "$(zoxide init bash)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/brent/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

