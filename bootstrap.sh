#!/bin/bash

# Ophalen via 
# curl -fsSL "http://bootstrap.diederik.be?$(date +%s)" --output bootstrap.sh && . bootstrap.sh  

##
# Color  Variables & functions
##
green='\e[32m'
blue='\e[34m'
red='\e[31m'
orange='\e[33m'
purple='\e[35m'
clear='\e[0m'
green(){
  echo -ne $green$1$clear
}
blue(){
  echo -ne $blue$1$clear
}
red(){
  echo -ne $red$1$clear
}
orange(){
  echo -ne $orange$1$clear
}

function splash() {

echo -ne "
   _____  _          _           _ _    _        
  |  __ \(_)        | |         (_) |  ( )       
  | |  | |_  ___  __| | ___ _ __ _| | _|/ ___    
  | |  | | |/ _ \/ _\` |/ _ \ '__| | |/ / / __|  
  | |__| | |  __/ (_| |  __/ |  | |   <  \__ \   
  |_____/|_|\___|\__,_|\___|_|  |_|_|\_\ |___/   
  |  _ \            | |     | |                  
  | |_) | ___   ___ | |_ ___| |_ _ __ __ _ _ __  
  |  _ < / _ \ / _ \| __/ __| __| '__/ _\` | '_ 
  | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) |
  |____/ \___/ \___/ \__|___/\__|_|  \__,_| .__/ 
                                          | |    
                                          |_|    

"

}

menu(){
echo -ne "
Install...
$(green '1)') Local bin dirs
$(green '2)') Chezmoi
$(green '3)') Bin install tool
$(green '4)') pnpm and node
$(green '5)') Popular Bin Installs
$(green '0)') Exit
$(blue 'Choose an option:') "
        read a </dev/tty
        case $a in
	        1) install-bin-dirs ; clear; splash; menu ;;
	        2) install-chezmoi ; clear; splash; menu ;;
	        3) install-bin-tool ; clear; splash; menu ;;
	        4) install-pnpm ; clear; splash; menu ;;
	        5) menu-bin-apps ; clear; splash; menu ;;
		0) echo -e $green"see you later..."$clear;;
		*) echo -e $red"Wrong option."$clear;;
        esac
}

menu-bin-apps(){
echo -ne "
Install popular binary apps...
$(green '1)') Github CLI - github.com/cli/cli
$(green '2)') Direnv - github.com/direnv/direnv
$(green '0)') Return
$(blue 'Choose an option:') "
        read a </dev/tty
        case $a in
	        1) bin install github.com/cli/cli ; clear; splash; menu-bin-apps ;;
	        2) bin install github.com/direnv/direnv ; clear; splash; menu-bin-apps ;;
		0) echo -e $green"returning..."$clear;;
		*) echo -e $red"Wrong option."$clear;;
        esac
}

add-to-path() {
    newelement=${1%/}
    if [ -d "$1" ] && ! echo $PATH | grep -E -q "(^|:)$newelement($|:)" ; then
        if [ "$2" = "after" ] ; then
            echo -e $green"Adding '$newelement' to head of path"$clear
            export PATH="$PATH:$newelement"
        else
            echo -e $green"Adding '$newelement' to tail of path"$clear
            export PATH="$newelement:$PATH"
        fi
    fi
}

rm-path() {
  PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

add-to-config() {
  grep -q -F "$2" "$1" 
  if [ $? -ne 0 ]; then
    echo -e $green"Adding line '$2' into file $1"$clear
    echo "" >> "$1" # To be sure add new line
    echo "$2" >> "$1"
  else
    echo -e $purple"line '$2' already added to file $1"$clear
  fi
}

install-bin-dirs() {
  mkdir -p "$HOME/bin"
  add-to-config ~/.bashrc 'export PATH="$HOME/bin:$PATH"'
  add-to-path "$HOME/bin"
  mkdir -p "$HOME/.local/bin"
  add-to-config ~/.bashrc 'export PATH="$HOME/.local/bin:$PATH"'
  add-to-path "$HOME/.local/bin"
  read -n 1 -s -r -p "*** Bin dirs are installed, press any key" </dev/tty
}

install-chezmoi() {
  sh -c "$(curl -fsLS git.io/chezmoi)"
  # sh -c "$(curl -fsLS git.io/chezmoi)" -- init --apply dieddc 
  read -n 1 -s -r -p "*** Chezmoi is installed, press any key" </dev/tty 
}

install-bin-tool() {
  # Werken met bin install tool - https://github.com/marcosnils/bin
  VERSION=`curl -fsSL "https://api.github.com/repos/marcosnils/bin/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-`
  echo ""
  echo "Getting bin tool version $VERSION..."
  URL="https://github.com/marcosnils/bin/releases/download/v${VERSION}/bin_${VERSION}_linux_x86_64"
  curl -fsSL $URL --output bintool >/dev/null
  chmod u+x ./bintool
  ./bintool install github.com/marcosnils/bin
  rm ./bintool
  read -n 1 -s -r -p "*** Bin tool is installed, press any key" </dev/tty
}

install-pnpm() {
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  PNPM_HOME="$HOME/.local/share/pnpm"
  add-to-path "$PNPM_HOME"
  pnpm env use --global 14
}

function all() {

  read -n 1 -s -r -p "*** Setup local bin and installing starship, press any key" </dev/tty
  echo ""
  echo "Getting starship..."

  # Locale bin dir aanmaken
  mkdir -p "$HOME/.local/bin"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 
  export PATH="$HOME/.local/bin:$PATH"

  # Installeren [Starship](https://starship.rs/guide)
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -b $HOME/.local/bin -y  >/dev/null
  echo 'eval "$(starship init bash)"' >> ~/.bashrc 
  eval "$(starship init bash)"

  echo ""
  read -n 1 -s -r -p "*** Setup bin install tool (github.com/marcosnils/bin), press any key" </dev/tty

  # Werken met bin install tool - https://github.com/marcosnils/bin
  VERSION=`curl -fsSL "https://api.github.com/repos/marcosnils/bin/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-`
  echo ""
  echo "Getting bin tool version $VERSION..."
  URL="https://github.com/marcosnils/bin/releases/download/v${VERSION}/bin_${VERSION}_linux_x86_64"
  curl -fsSL $URL --output bin >/dev/null
  chmod u+x ./bin
  ./bin install github.com/marcosnils/bin
  rm ./bin

  # Installatie van NVM
  echo ""
  read -n 1 -s -r -p "*** Installing NVM, press any key" </dev/tty
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm install node
  npm install -g pnpm

  # Installatie van mask
  bin install github.com/jakedeichert/mask

  echo ""
  read -n 1 -s -r -p "*** All OK, press any key"  </dev/tty
  clear

  # Ophalen van markdown bootstrap om te draaien met mask
  curl -fsSL "https://gist.github.com/dieddc/39eda6030d456812222822d7229780a4/raw" --output bootstrap.md
  # Adding alias for starting mask with bootstrap
  alias bts='mask --maskfile ~/shared/bootstrap.md'  #!!! TEST CODDE
  echo "All installed, extra installs:"
  echo "Installing github CLI => bts gh"
  echo "Installing Bitwarden => bts bw"

}

# Starting
clear
splash
menu

# Test commands in LXC
: '
source ~/shared/bootstrap.sh 
echo $PATH
'
