#!/bin/bash

# -e: exit on error
# -u: exit on unset variables
set -eu

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
gray='\e[37m'
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
purple(){
  echo -ne $purple$1$clear
}

log_color() {
  color_code="$1"
  shift
  printf "\033[${color_code}%s\033[0m\n" "  $*" >&2
}
log() {
  log_color "0;$purple" "$@"
}
log-green() {
  log_color "0;$green" "$@"
}
log-blue() {
  log_color "0;$blue" "$@"
}
log-red() {
  log_color "0;$red" "$@"
}
log-orange() {
  log_color "0;$orange" "$@"
}
log-task() {
  log-blue "🔃" "$@"
}
log-error() {
  log-red "❌" "$@"
}
error() {
  log-error "$@"
  exit 1
}
log-job() {
  clear
  printf "🔃"
  printf "\033[0,$blue%s\033[0m" "  $@" >&2
  read -n 1 -s -r -p " <Press any key>" </dev/tty
  printf "\n"
}
wait-for-key() {
  read -n 1 -s -r -p "<Press any key>" </dev/tty
  printf "\n"
}

splash() {

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

  \n"

}

menu() {
  echo -ne "
  Install...
  $(green '1)') Base tools for development
  $(green '2)') Zsh shell and dotfiles (chezmoi)
  $(green '3)') Pnpm & Node
  $(green '4)') Popular Bin Installs
  $(green '0)') Exit
  $(purple 'Choose an option:') "
          read a </dev/tty
          case $a in
            1) install-base ; clear; splash; menu ;;
            2) install-zsh ; clear; splash; menu ;;
            3) install-pnpm ; clear; splash; menu ;;
            4) menu-bin-apps ; clear; splash; menu ;;
      0) log "see you later...";;
      *) log-red "Wrong option.";;
          esac
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

check-user() {
  current_user=$(whoami)
  if id $USERNAME >/dev/null 2>&1;
  then
    log-green "Standard Development User $USERNAME exists"
    if [ "$current_user" = "$USERNAME" ]; 
    then 
      log "Running as $USERNAME, we can proceed..."
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
      add-user
    else  
      echo -e $red" Please start as ROOT for adding the user $USERNAME"$clear
      exit 0
    fi
  fi    
}

add-user() {
  # Adding group with same name as user
  groupadd --gid 1000 ${USERNAME}
  # Adding user and create home dir
  useradd --uid 1000 --gid ${USERNAME} --shell /bin/bash --create-home ${USERNAME}
  # add empty password to user
  # passwd -d ${USERNAME}
  # Give user sudo rights
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
  chmod 0440 /etc/sudoers.d/${USERNAME}      
  # Adding a password for the user
  echo -e $green" Please add a password for user 'passwd $USERNAME' and restart session."$clear
  exit 0
}

install-base() {

  log-job "Performing updates"
  sudo apt update --yes
  
  log-job "Adding standard HOME dirs"
  add-dir "$HOME/bin"
  add-dir "$HOME/.local/bin"
  add-dir "$HOME/repo"

  if ! command -v git >/dev/null 2>&1; then
    log-job "Installing git"
    sudo apt install git --yes
  fi

  wait-for-key

}

install-python() {

  if ! command -v pip &> /dev/null
  then
    log-job "Python & pip not found, will be installed"
    sudo apt install -y python3-venv python3-pip
  fi  

  if ! command -v pipx &> /dev/null
  then
    log-job "Python pipx not found, will be installed"
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
  fi  

  wait-for-key

}

# Replacing sudo command for pre cheking if all is OK
sudo() {
  # shellcheck disable=SC2312
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    if ! command sudo --non-interactive true 2>/dev/null; then
      log_manual_action "Root privileges are required, please enter your password below"
      command sudo --validate
    fi
    command sudo "$@"
  fi
}


install-zsh() {

  if ! command -v zsh &> /dev/null
  then
    log-job "Installing zsh"
    sudo apt install -y zsh
  fi  

  # Change shell of user
  sudo usermod --shell /bin/zsh $USERNAME

  # Install OH-MY-ZSH
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  DOTFILES_REPO_HOST=${DOTFILES_REPO_HOST:-"https://github.com"}
  DOTFILES_USER=${DOTFILES_USER:-"dieddc"}
  DOTFILES_REPO="${DOTFILES_REPO_HOST}/${DOTFILES_USER}/dotfiles"
  DOTFILES_BRANCH=${DOTFILES_BRANCH:-"master"}
  DOTFILES_DIR="${HOME}/.dotfiles"

  if ! command -v git >/dev/null 2>&1; then
    log-task "Installing git"
    sudo apt update --yes
    sudo apt install git --yes
  fi

  if [ -d "${DOTFILES_DIR}" ]; then
    #git_clean "${DOTFILES_DIR}" "${DOTFILES_REPO}" "${DOTFILES_BRANCH}"
    error ".dotfiles dir already exists, no new installation"
  else
    log-task "Cloning '${DOTFILES_REPO}' at branch '${DOTFILES_BRANCH}' to '${DOTFILES_DIR}'"
    git clone --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"
  fi

  clear
  log-task "Zsh, Oh-my-zsh and Chezmoi dotfiles are installed, please restart session for activating the shell"
  wait-for-key

}

# Starting
USERNAME=dev
clear
splash
check-user
menu

