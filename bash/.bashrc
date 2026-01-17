#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '
export EDITOR="nvim"
export VISUAL="code --wait"
export HISTCONTROL=ignoreboth

# Created by `pipx` on 2025-12-19 14:04:00
export PATH="$PATH:/home/ben/.local/bin"

alias vpn='sudo vpnc n7-vpn.conf'
alias vpnd='sudo vpnc disconnect'
