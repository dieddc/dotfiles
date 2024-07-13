#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
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
$(green '1)') Base install development
$(green '2)') Pnpm base installs
$(green '3)') Bin install tool
$(green '4)') Chezmoi
$(green '5)') Popular Bin Installs
$(green '0)') Exit
$(blue 'Choose an option:') "
        read a </dev/tty
        case $a in
	        1) install-base ; clear; splash; menu ;;
	        2) install-pnpm ; clear; splash; menu ;;
	        3) install-bin-tool ; clear; splash; menu ;;
	        4) install-chezmoi ; clear; splash; menu ;;
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

add-dir() {
  DIR=${1%/}
  if [ -d "$DIR" ];
  then
    green $DIR
    echo -e " directory already exists"
  else
    mkdir -p "$DIR"
    orange $DIR
    echo -e " directory created"
  fi    
}

check-user() {
  USERNAME=${1%/}
  if id $USERNAME >/dev/null 2>&1;
  then
    echo -e $green" Standard Development User $USERNAME exists"$clear
    if [ "$USER" = "$USERNAME" ]; 
    then 
      echo -e " Running as $USERNAME, we can proceed..."
    else  
      echo -e $red" You are root, please run the bootstrap as user $USERNAME"$clear
      exit 0
    fi
  else
    echo -e $orange" We need to add the user $USERNAME"$clear
    if [ $UID = 0 ];
    then 
      check-sudo
      if getent passwd 1000 >/dev/null; 
      then  
        echo -e $red" USER ID 1000 is occupied"$clear
        exit 0
      fi    
      add-user $USERNAME
    else  
      echo -e $red" Please start as ROOT for adding the user $USERNAME"$clear
      exit 0
    fi
  fi    
}

# installeer basis, steeds controleren
check-sudo() {
  # We always need sudo
  if ! command -v sudo &> /dev/null
  then
    read -n 1 -s -r -p "*** Performing apt update" </dev/tty 
    apt-get update
    clear
    read -n 1 -s -r -p "*** sudo not found, will be installed" </dev/tty 
    apt-get install --no-install-recommends -y sudo
    clear
  fi    
}

add-user() {
  USERNAME=${1%/}
  # Adding group with same name as user
  groupadd --gid 1000 ${USERNAME}
  # Adding user and create home dir
  useradd --uid 1000 --gid ${USERNAME} --shell /bin/bash --create-home ${USERNAME}
  # add empty password to user
  passwd -d ${USERNAME}
  # Give user sudo rights
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
  chmod 0440 /etc/sudoers.d/${USERNAME}      
  # Adding a password for the user
  echo -e $green" Please add a password for user $USERNAME..."$clear
  passwd ${USERNAME}
  # We need to restart as user
  echo -e $green" Restart session as user $USERNAME"$clear
  exit 0
}


install-base() {

  read -n 1 -s -r -p "*** Performing apt update" </dev/tty 
  sudo apt update
  clear

  read -n 1 -s -r -p "*** Adding standard HOME dirs" </dev/tty
  echo ""
  add-dir "$HOME/bin"
  add-dir "$HOME/.local/bin"
  add-dir "$HOME/dev/repo"
  echo ""

  if ! command -v pip &> /dev/null
  then
      read -n 1 -s -r -p "*** Python pip not found, will be installed" </dev/tty 
      sudo apt install -y python3-venv python3-pip    
      clear
  fi  

  if ! command -v pipx &> /dev/null
  then
      read -n 1 -s -r -p "*** Python pipx not found, will be installed" </dev/tty 
      python3 -m pip install --user pipx
      python3 -m pipx ensurepath  
  fi  

  if [ ! -f ~/.local/bin/install-release ]
  then
      read -n 1 -s -r -p "*** Installing install-release tool" </dev/tty 
      ~/.local/bin/pipx install install-release
  fi

  if ! command -v pnpm &> /dev/null
  then
      read -n 1 -s -r -p "*** pnpm not found, will be installed" </dev/tty 
      curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi  

  echo ""
  read -n 1 -s -r -p "*** Please restart your session" </dev/tty 
  clear
  exit

}

install-pnpm() {
   pnpm env use --global lts
   pnpm add -g zx
   sudo apt install -y zip unzip
   curl -fsSL https://deno.land/x/install/install.sh | sh
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

install-zsh() {
  sudo apt update
  sudo apt install -y zsh
  chsh -s $(which zsh)
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
check-user "ddc"
menu
# install-base

