function load_zsh_syntax_highlighting() {
  source $MYZSH_PATH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
  source $MYZSH_PATH/config/zsh-syntax-highlighting.zsh
}

function load_zsh_autosuggestions() {
  source $MYZSH_PATH/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
  source $MYZSH_PATH/config/zsh-autosuggestions.zsh
}

function load_fzf() {
  source <(fzf --zsh)
}

function load_nvm() {
  if [ -d "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi
  command -v npm &>/dev/null && export PATH=$PATH:$(npm prefix -g)/bin
}

function load_dircolors() {
  # enable color support of ls, less and man, and also add handy aliases
  if [ -x /usr/bin/dircolors ]; then
      test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

      alias ls='ls --color=auto'
      #alias dir='dir --color=auto'
      #alias vdir='vdir --color=auto'

      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'
      alias diff='diff --color=auto'
      alias ip='ip --color=auto'

      export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
      export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
      export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
      export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
      export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
      export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
      export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

      # Take advantage of $LS_COLORS for completion as well
      zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
  fi
}

function zvm_after_init() {
  # bindkey '^[[A' history-substring-search-up
  # bindkey '^[[B' history-substring-search-down

  # [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # zvm_bindkey viins '^R' fzf-history-widget

  zsh-defer source $MYZSH_PATH/bindkey.zsh
  zsh-defer load_fzf
}

_deferred_init_done=0
_deferred_init() {
  (( _deferred_init_done )) && return
  _deferred_init_done=1

  zsh-defer source $MYZSH_PATH/plugins/zsh-you-should-use/you-should-use.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/git/git.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/web-search/web-search.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/jsontools/jsontools.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/docker/docker.plugin.zsh
  zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/docker-compose/docker-compose.plugin.zsh

  zsh-defer load_nvm
}

# 立即加载常用的插件
source $MYZSH_PATH/plugins/zsh-defer/zsh-defer.plugin.zsh
source $MYZSH_PATH/export.zsh
source $MYZSH_PATH/alias.zsh

source $MYZSH_PATH/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# 异步加载, 让提示符加快出现
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/lib/clipboard.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/lib/directories.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/z/z.plugin.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/copypath/copypath.plugin.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/copyfile/copyfile.plugin.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/sudo/sudo.plugin.zsh
zsh-defer source $MYZSH_PATH/plugins/ohmyzsh/plugins/command-not-found/command-not-found.plugin.zsh
zsh-defer load_dircolors
zsh-defer load_zsh_syntax_highlighting
zsh-defer load_zsh_autosuggestions

# 第一个命令之后再加载其他插件
autoload -Uz add-zsh-hook
add-zsh-hook preexec _deferred_init
