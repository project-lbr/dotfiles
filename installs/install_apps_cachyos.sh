#!/bin/bash

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Protection against running as root/sudo
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Chyba: Nespouštěj tento skript pod sudo nebo jako root!${NC}"
  echo "Skript si o práva root (sudo) požádá sám, až je bude potřebovat."
  exit 1
fi

# CachyOS detection (this script is for CachyOS only)
IS_CACHYOS=false
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "cachyos" ] || grep -qi "cachyos" /etc/os-release; then
    IS_CACHYOS=true
  fi
fi

if [ "$IS_CACHYOS" = false ]; then
  echo -e "${RED}Chyba: Tento skript je optimalizován a určen výhradně pro CachyOS!${NC}"
  echo "Pro běžný Arch Linux nebo EndeavourOS použij skript install_apps.sh."
  exit 1
fi

echo -e "${BLUE}Začínám instalaci aplikací na CachyOS...${NC}"

# --- PACKAGE LIST (Optimized for CachyOS) ---
PKGS=(
  # Internet & Communication (Zen and LibreWolf straight from the CachyOS repo instead of AUR)
  "zen-browser" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden" "obsidian" "librewolf"
  "stoat-desktop-bin"

  # Media & Office
  "vlc" "spotify" "onlyoffice-bin" "okular" "obs-studio" "droidcam" "freecad"
  "audacity"

  # Editors & Development
  "visual-studio-code-bin" "neovim" "micro" "git" "lazygit" "antigravity"

  # Terminal & Shell
  "kitty" "fish" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tealdeer" "curl" "fd" "ncdu" "eza" "sesh-bin" "tmux"

  # System Tools (CachyOS uses the native Btrfs Assistant instead of Timeshift)
  "btrfs-assistant" "flameshot" "stow" "syncthing" "openssh"
)

echo -e "${BLUE}Aktualizuji systém...${NC}"
sudo pacman -Syu --noconfirm

# Install paru from the CachyOS repos (no need to build from AUR)
if ! command -v paru &>/dev/null; then
  echo -e "${BLUE}'paru' nebyl nalezen. Instaluji ho z repozitáře CachyOS...${NC}"
  sudo pacman -S --needed --noconfirm paru
fi

echo -e "${BLUE}Instaluji balíčky pomocí paru...${NC}"
paru -S --needed --noconfirm "${PKGS[@]}"

echo -e "${GREEN}Instalace aplikací na CachyOS dokončena!${NC}"
