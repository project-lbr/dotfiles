#!/bin/bash

# --- Barvičky ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Ochrana před spuštěním pod rootem/sudo
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Chyba: Nespouštěj tento skript pod sudo nebo jako root!${NC}"
  echo "Skript si o práva root (sudo) požádá sám, až je bude potřebovat."
  exit 1
fi

# Detekce a blokování CachyOS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "cachyos" ] || grep -qi "cachyos" /etc/os-release; then
    echo -e "${RED}This script is not working on CachyOS distribution. Please copy manually dotfiles or try to look for another dotfiles repository that is made for CachyOS, Thanks.${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}Začínám instalaci aplikací...${NC}"

# --- 3. SEZNAM BALÍČKŮ (Tuxmate) ---
PKGS=(
  # Internet a Komunikace
  "zen-browser-bin" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden" "obsidian" "librewolf-bin"
  "stoat-desktop-bin"

  # Média a Kancelář
  "vlc" "spotify" "onlyoffice-bin" "okular" "obs-studio" "droidcam" "freecad"
  "audacity"

  # Editory a Vývoj
  "visual-studio-code-bin" "neovim" "micro" "git" "lazygit" "antigravity"

  # Terminál a Shell
  "kitty" "zsh" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tldr" "curl" "fd" "ncdu"

  # Systémové nástroje
  "timeshift" "flameshot" "stow" "syncthing" "openssh"
)

echo -e "${BLUE}Aktualizuji systém...${NC}"
sudo pacman -Syu --noconfirm

# Automatická instalace paru, pokud chybí
if ! command -v paru &>/dev/null; then
  echo -e "${BLUE}'paru' nebyl nalezen. Instaluji 'paru-bin' z AUR...${NC}"
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
  cd /tmp/paru-bin
  makepkg -si --noconfirm
  cd - &>/dev/null
  rm -rf /tmp/paru-bin
fi

echo -e "${BLUE}Instaluji balíčky pomocí paru...${NC}"
paru -S --needed --noconfirm "${PKGS[@]}"

echo -e "${GREEN}Instalace aplikací dokončena!${NC}"
