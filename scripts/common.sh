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
