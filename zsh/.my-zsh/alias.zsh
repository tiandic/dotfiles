# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

if cat /etc/os-release | grep -i debian ; then
  alias i="sudo apt install"
  alias u="sudo apt update"
  alias ud="sudo apt update && sudo apt dist-upgrade -y"
  alias pu="sudo -E $HOME/bin/apt-proxy update"
  alias pi="sudo -E $HOME/bin/apt-proxy install"
  alias pud="sudo -E $HOME/bin/apt-proxy update && sudo $HOME/bin/apt-proxy dist-upgrade"
  alias di="sudo dpkg -i"
elif cat /etc/os-release | grep -i arch ; then
  alias paS="sudo pacman -S"
  alias paSyu="sudo pacman -Syu"
fi

alias md="mkdir"
alias py="python3"
alias trm="trash-put"
alias rcp="rsync -avhP --info=progress2 --no-inc-recursive"
#alias fd="fdfind"
alias ipy="ipython3"

alias ssh="kitty +kitten ssh"
alias icat="kitty +kitten icat"

alias gac="git add . && git commit -m"
