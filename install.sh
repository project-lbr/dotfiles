#!/bin/bash

# --- 1. NASTAVENÍ ---
GITHUB_USER="project-lbr"
REPO_NAME="dotfiles"

# --- Barvičky ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Začínám instalaci tvého systému...${NC}"

# --- 2. Příprava (Git a Dotfiles) ---
echo -e "${BLUE}Kontroluji existenci dotfiles...${NC}"

# Pokud nemáme git, nainstalujeme ho
if ! command -v git &>/dev/null; then
  echo "Git nenalezen. Instaluji..."
  sudo pacman -S --noconfirm git
fi

# Pokud složka neexistuje, naklonujeme ji
if [ ! -d "$HOME/$REPO_NAME" ]; then
  echo -e "${GREEN}Klonuji repozitář z GitHubu ($GITHUB_USER)...${NC}"
  git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git" "$HOME/$REPO_NAME"
else
  echo -e "${GREEN}Složka dotfiles již existuje. Aktualizuji...${NC}"
  cd "$HOME/$REPO_NAME" && git pull
fi

# --- 3. SEZNAM BALÍČKŮ (Tuxmate) ---
PKGS=(
  # Internet a Komunikace
  "zen-browser-bin" "firefox" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden"

  # Média a Kancelář
  "vlc" "spotify" "libreoffice-fresh" "okular"

  # Editory a Vývoj
  "code" "neovim" "micro" "git" "lazygit"

  # Terminál a Shell
  "kitty" "zsh" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tldr" "curl" "fd"

  # Systémové nástroje
  "timeshift" "flameshot" "stow"
)

# --- 4. Aktualizace a Instalace ---
echo -e "${BLUE}Aktualizuji systém a instaluji programy...${NC}"
sudo pacman -Syu --noconfirm

if command -v yay &>/dev/null; then
  yay -S --needed --noconfirm "${PKGS[@]}"
else
  echo -e "${RED}Chyba: Nemáš nainstalovaný 'yay'.${NC}"
  echo "Na čistém Archu ho musíš nejdřív nainstalovat ručně."
  exit 1
fi

# --- 5. Aplikace Configů (Stow) ---
echo -e "${BLUE}Propojuji dotfiles pomocí Stow...${NC}"

cd "$HOME/$REPO_NAME"

# Seznam složek k propojení
STOW_DIRS=(
  "fastfetch"
  "lazygit"
  "yazi"
  "kitty"
  # "neovim"
  # "zsh"
)

for dir in "${STOW_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}Stowuji: $dir${NC}"
    # --restow zajistí opravu odkazů, pokud už existují
    stow --restow "$dir"
  else
    echo "Složka '$dir' v dotfiles neexistuje."
  fi
done

# --- 6. Přepnutí Shellu ---
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
  echo -e "${BLUE}Měním výchozí shell na Zsh...${NC}"
  chsh -s /usr/bin/zsh
fi

echo -e "${GREEN}HOTOVO! Restartuj terminál (nebo PC).${NC}"
