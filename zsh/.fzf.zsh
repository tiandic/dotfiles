# Setup fzf
# ---------
if [[ ! "$PATH" == */home/a/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/a/.fzf/bin"
fi

source <(fzf --zsh)
