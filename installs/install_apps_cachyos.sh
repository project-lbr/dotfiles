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

# Detekce CachyOS (skript je určen pouze pro CachyOS)
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

# --- SEZNAM BALÍČKŮ (Optimalizovaný pro CachyOS) ---
PKGS=(
  # Internet a Komunikace (Zen a LibreWolf přímo z CachyOS repo místo AUR)
  "zen-browser" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden" "obsidian" "librewolf"
  "stoat-desktop-bin"

  # Média a Kancelář
  "vlc" "spotify" "onlyoffice-bin" "okular" "obs-studio" "droidcam" "freecad"
  "audacity"

  # Editory a Vývoj
  "visual-studio-code-bin" "neovim" "micro" "git" "lazygit" "antigravity"

  # Terminál a Shell
  "kitty" "zsh" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tldr" "curl" "fd" "ncdu"

  # Systémové nástroje (místo Timeshiftu používá CachyOS nativní Btrfs Assistant)
  "btrfs-assistant" "flameshot" "stow" "syncthing" "openssh"
)

echo -e "${BLUE}Aktualizuji systém...${NC}"
sudo pacman -Syu --noconfirm

# Instalace paru z repozitářů CachyOS (není potřeba kompilovat z AUR)
if ! command -v paru &>/dev/null; then
  echo -e "${BLUE}'paru' nebyl nalezen. Instaluji ho z repozitáře CachyOS...${NC}"
  sudo pacman -S --needed --noconfirm paru
fi

echo -e "${BLUE}Instaluji balíčky pomocí paru...${NC}"
paru -S --needed --noconfirm "${PKGS[@]}"

echo -e "${GREEN}Instalace aplikací na CachyOS dokončena!${NC}"
