#!/bin/sh

green='\e[32m'
blue='\e[34m'
red='\e[31m'
orange='\e[33m'
purple='\e[35m'
clear='\e[0m'

# include .profile if it exists.
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

echo $green"Installing node and npm..."$clear
pnpm env use --global lts

echo $blue"Basic tools are installed..."$clear

echo $orange"Python3: "$clear"$(python3 --version)"
echo $orange"Pipx: "$clear"$(pipx --version)"
echo $orange"Pnpm: "$clear"$(pnpm --version)"
echo $orange"Node: "$clear"$(node --version)"
echo $orange"Npm: "$clear"$(npm --version)"

echo $green"Changing shell to ZSH, enter password..."$clear
chsh -s $(which zsh)

echo $purple"Please logoff and logon to proceed."$clear

