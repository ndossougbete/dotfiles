#########################
# Set up the prompt
#########################

autoload -U colors && colors

autoload -Uz vcs_info

zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git

# applied in the precmd section

setopt prompt_subst

function exit_code_dependent_color_() {
  if [[ $? = "0" ]]; then
    echo 'green'
  else
    echo 'red'
  fi
}

PROMPT='%{$fg_bold[$(exit_code_dependent_color_)]%}%n@%m ${vcs_info_msg_0_} %{$fg_bold[blue]%}%~
%#%{$reset_color%} '


#########################
# History and stuff
#########################

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
#bindkey -e # huh? why is it there?

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history


#########################
# Completion
#########################

# Use modern completion system
autoload -Uz compinit
compinit -i


zstyle ':completion:*' auto-description 'specify: %d'
# zstyle ':completion:*' completer _expand _complete _correct _approximate
# zstyle ':completion:*' format 'Completing %d'
# zstyle ':completion:*' group-name ''
# zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
# zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z-_}={A-Za-z_-}'
# zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
# zstyle ':completion:*' menu select=long
# zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*' max-errors 3 numeric


#########################
# History and cd -
#########################

setopt AUTO_CD
setopt hist_verify
unsetopt list_ambiguous
setopt chase_links

# cd auto pushes to the stack
setopt auto_pushd
setopt pushd_ignore_dups
# Doesn't display the stack on pushd
setopt pushd_silent
# pushd without args pushes $HOME
setopt pushd_to_home

##########################
# Aliases
##########################

alias ls='ls --tabsize=0 --literal --color=auto --show-control-chars --human-readable'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias -g G='| egrep'
alias -g H='| egrep -e "$" -e'

# Stop complaining about py files indented with 2 spaces
alias pep8='pep8 --ignore=E111,E114'

##
# Example find all the cc files that contain DLOG in the src directory
#   rg *.cc DLOG src/
rg()
{
    filepat="$1"
    pat="$2"
    shift 2
    grep -Er --include=$filepat $pat ${@:-.}
}
alias rg='noglob rg'

##
# Example: rename all the html files in the current file tree
#   fname *.html each rename 's/.html$/.var/'
function fname() {
  noglob find $1 -name $2
}
alias -g each="-print0 | xargs -0"

function pull-bug-reports() {
  (
    mkdir -p bugreports && cd bugreports && adb pull data/data/com.android.shell/files/bugreports
  )
}


push-prop() {
  if [ $# -eq 0 -o ! -f $1 ]; then
    echo "A file need to be provided. Found '$1'."
    return 1
  fi

  adb push $1 /data/local.prop

  if [ $? -ne 0 ]; then
    echo "The command failed. adb needs to be root."
    return 1
  fi

  adb shell chmod 644 /data/local.prop
  adb reboot

  #You can double check to make sure that the values in local.prop were read by executing:
  #adb shell getprop | grep log.tag
}


# prints the name of the parent branch in git.
parent-branch() {
  (
    git show-branch | sed "s/].*//" | grep "\*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed "s/^.*\[//"
  )
}


LC_GREP_INCLUSION_FILTER="'(^(V|D|I|W|E|WTF)/cr)|DGN|FATAL|/System.err|(^(V|D|I|W|E|WTF)/dgn)|TestRunner'"

alias alc="adb logcat -v tag"
alias ald="adb logcat -d -v tag"
alias alcl="adb logcat -c"
alias alcc="alcl && alc"
alias alcg="alc G -e ${LC_GREP_INCLUSION_FILTER}"
alias alch="alc H ${LC_GREP_INCLUSION_FILTER}"
alias aldg="ald G -e ${LC_GREP_INCLUSION_FILTER}"
alias aldh="ald H ${LC_GREP_INCLUSION_FILTER}"
alias alccg="alcl && alcg"
alias alcch="alcl && alch"

##########################
# Variables
##########################
export PATH="${PATH}:${HOME}/Scripts"
export ANDROID_LOG_TAGS="BluetoothManagerService:W HeadsetStateMachine:W WifiService:W Sensors:S WifiStateMachine:S dalvikvm:E"

# Always colorize grep output except when it's piped somewhere.
export GREP_OPTIONS="--color=auto"

# TODO For working python scripts
#export PYTHONPATH=$PYTHONPATH:${HOME}/Projects/py_modules

##########################
# Other scripts
##########################


eval $(thefuck --alias)

##########################
# Precmd
##########################

function get-vcs-status() {
  # VCS Status
  if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
    zstyle ':vcs_info:*' formats '%F{blue}[%F{green}%b%c%u%F{blue}]'
  } else {
    zstyle ':vcs_info:*' formats '%F{blue}[%F{green}%b%c%u%F{red}●%F{blue}]'
  }
  vcs_info
}

[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions get-vcs-status)
