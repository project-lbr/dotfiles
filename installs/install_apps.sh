#!/bin/bash

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Protection against running as root/sudo
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Error: Do not run this script as sudo or root!${NC}"
  echo "The script will ask for root (sudo) privileges itself when it needs them."
  exit 1
fi

# Detection and blocking of CachyOS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "cachyos" ] || grep -qi "cachyos" /etc/os-release; then
    echo -e "${RED}This script is not working on CachyOS distribution. Please copy manually dotfiles or try to look for another dotfiles repository that is made for CachyOS, Thanks.${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}Starting application installation...${NC}"

# --- 3. PACKAGE LIST (Tuxmate) ---
PKGS=(
  # Internet & Communication
  "zen-browser-bin" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden" "obsidian" "librewolf-bin"
  "stoat-desktop-bin"

  # Media & Office
  "vlc" "spotify" "onlyoffice-bin" "okular" "obs-studio" "droidcam" "freecad"
  "audacity"

  # Editors & Development
  "visual-studio-code-bin" "neovim" "micro" "git" "lazygit" "antigravity"

  # Terminal & Shell
  "kitty" "zsh" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tldr" "curl" "fd" "ncdu"

  # System Tools
  "timeshift" "flameshot" "stow" "syncthing" "openssh"
)

echo -e "${BLUE}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# Automatic installation of paru if missing
if ! command -v paru &>/dev/null; then
  echo -e "${BLUE}'paru' was not found. Installing 'paru-bin' from AUR...${NC}"
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
  cd /tmp/paru-bin
  makepkg -si --noconfirm
  cd - &>/dev/null
  rm -rf /tmp/paru-bin
fi

echo -e "${BLUE}Installing packages using paru...${NC}"
paru -S --needed --noconfirm "${PKGS[@]}"

echo -e "${GREEN}Application installation completed!${NC}"
