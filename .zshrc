# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/harsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
. /home/harsh/scripts/z.sh
eval export POSH_THEME="/home/harsh/.cache/oh-my-posh/config.omp.json"
export POWERLINE_COMMAND="oh-my-posh"
export CONDA_PROMPT_MODIFIER=false

# set secondary prompt
PS2="$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --config="$POSH_THEME" --shell=zsh --print-secondary)"

function _omp-preexec() {
  omp_start_time=$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --millis)
}

function _omp-precmd() {
  omp_last_error=$?
  omp_stack_count=${#dirstack[@]}
  omp_elapsed=-1
  if [ $omp_start_time ]; then
    omp_now=$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --millis)
    omp_elapsed=$(($omp_now-$omp_start_time))
  fi
  eval "$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --config="$POSH_THEME" --error="$omp_last_error" --execution-time="$omp_elapsed" --stack-count="$omp_stack_count" --eval --shell=zsh)"
  unset omp_start_time
  unset omp_now
  unset omp_elapsed
  unset omp_last_error
  unset omp_stack_count
}

function _install-omp-hooks() {
  for s in "${preexec_functions[@]}"; do
    if [ "$s" = "_omp-preexec" ]; then
      return
    fi
  done
  preexec_functions+=(_omp-preexec)

  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "_omp-precmd" ]; then
      return
    fi
  done
  precmd_functions+=(_omp-precmd)
}

if [ "$TERM" != "linux" ]; then
  _install-omp-hooks
fi

function export_poshconfig() {
    [ $# -eq 0 ] && { echo "Usage: $0 \"filename\""; return; }
    format=$2
    if [ -z "$format" ]; then
      format="json"
    fi
    /home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --config="$POSH_THEME" --print-config --format="$format" > $1
}

function self-insert() {
  # ignore an empty buffer
  if [[ -z  "$BUFFER"  ]]; then
    zle .self-insert
    return
  fi
  tooltip=$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --config="$POSH_THEME" --shell=zsh --command="$BUFFER")
  # ignore an empty tooltip
  if [[ ! -z "$tooltip" ]]; then
    RPROMPT=$tooltip
    zle .reset-prompt
  fi
  zle .self-insert
}

function enable_poshtooltips() {
  zle -N self-insert
}

_posh-zle-line-init() {
    [[ $CONTEXT == start ]] || return 0

    # Start regular line editor
    (( $+zle_bracketed_paste )) && print -r -n - $zle_bracketed_paste[1]
    zle .recursive-edit
    local -i ret=$?
    (( $+zle_bracketed_paste )) && print -r -n - $zle_bracketed_paste[2]

    eval "$(/home/linuxbrew/.linuxbrew/Cellar/oh-my-posh/7.32.0/bin/oh-my-posh --config="$POSH_THEME" --print-transient --eval --shell=zsh)"
    zle .reset-prompt

    # If we received EOT, we exit the shell
    if [[ $ret == 0 && $KEYS == $'\4' ]]; then
        exit
    fi

    # Ctrl-C
    if (( ret )); then
        zle .send-break
    else
        # Enter
        zle .accept-line
    fi
    return ret
}

function enable_poshtransientprompt() {
  zle -N zle-line-init _posh-zle-line-init
}
