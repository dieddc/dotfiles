#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Installs any and all dependencies required to get the toolbox install.sh script to work

# Check if the script is running as root (in a Docker container). If so, we do
# not need to use sudo. If not, then we do need to use sudo.
if [ "$(id -u)" = "0" ]; then
    SUDO=""
    apt-get update
    apt-get install --no-install-recommends -y sudo
else
    SUDO="sudo"
    sudo apt-get update
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed. Installing Ansible..."
    $SUDO apt-get update
    $SUDO apt-get install ansible -y
    $SUDO ansible-galaxy collection install community.general    
    echo "Ansible has been installed."
else
    echo "Ansible is already installed."
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║ You should be good to run ansible now                      ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"