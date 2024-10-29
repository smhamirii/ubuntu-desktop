#!/bin/bash

# Exit on error
set -e

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Configuration
read -p "Enter username: " USER
read -s -p "Enter password: " PASSWORD
echo

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y || {
    echo "Failed to update system"
    exit 1
}

# Install desktop environment
echo "Installing Ubuntu desktop..."
apt install -y ubuntu-desktop || {
    echo "Failed to install desktop environment"
    exit 1
}

# Install XRDP
echo "Installing XRDP..."
apt install -y xrdp || {
    echo "Failed to install XRDP"
    exit 1
}

# Create user
echo "Creating user account..."
useradd -m -s /bin/bash "$USER" || {
    echo "Failed to create user"
    exit 1
}
echo "$USER:$PASSWORD" | chpasswd

# Configure sudo access
echo "$USER ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/$USER"
chmod 0440 "/etc/sudoers.d/$USER"

# Configure XRDP
echo "Configuring XRDP..."
su - "$USER" -c 'echo "gnome-session" > ~/.xsession'
systemctl restart xrdp
systemctl enable xrdp

# Install additional tools
echo "Installing additional tools..."
apt install -y wget || {
    echo "Failed to install additional tools"
    exit 1
}

# Create Documents directory and set permissions
echo "Setting up user directory..."
su - "$USER" -c 'mkdir -p ~/Documents'


echo "Setup complete! Please test the remote connection."
echo "Your username is: $USER"
echo "Remote desktop port: 3389"
