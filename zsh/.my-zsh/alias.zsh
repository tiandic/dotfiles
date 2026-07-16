# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

try_set_alias(){
  local target_cmd="$1"
  local raw_cmd="$2"

  local exec_name=$(echo "$raw_cmd" | awk '{print $1}')

  command -v "$exec_name" &> /dev/null && alias "$target_cmd=$raw_cmd"
}

if cat /etc/os-release | grep -q -i debian ; then
  alias i="sudo apt install"
  alias u="sudo apt update"
  alias ud="sudo apt update && sudo apt dist-upgrade -y"
  alias pu="sudo -E $HOME/bin/apt-proxy update"
  alias pi="sudo -E $HOME/bin/apt-proxy install"
  alias pud="sudo -E $HOME/bin/apt-proxy update && sudo $HOME/bin/apt-proxy dist-upgrade"
  alias di="sudo dpkg -i"

  alias fd=fdfind
elif cat /etc/os-release | grep -q -i arch ; then
  alias paS="sudo pacman -S"
  alias paSyu="sudo pacman -Syu --disable-download-timeout"
fi

alias md="mkdir"
try_set_alias py "python3"
try_set_alias trm "trash-put"
try_set_alias rcp "rsync -avhP --info=progress2 --no-inc-recursive"
try_set_alias ipy "ipython3"

# kitty
try_set_alias ssh "kitty +kitten ssh"
try_set_alias icat "kitty +kitten icat"

# git
try_set_alias gac "git add . && git commit -m"
try_set_alias gc "git clone"
