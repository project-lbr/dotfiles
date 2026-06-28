#!/bin/bash

# --- 1. NASTAVENÍ ---
GITHUB_USER="project-lbr"
REPO_NAME="dotfiles"

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

echo -e "${BLUE}Nastavuji dotfiles a Stow...${NC}"

# --- 2. Příprava (Git a Dotfiles) ---
echo -e "${BLUE}Kontroluji existenci dotfiles...${NC}"

# Pokud nemáme git, nainstalujeme ho
if ! command -v git &>/dev/null; then
  echo "Git nenalezen. Instaluji..."
  sudo pacman -S --noconfirm git
fi

# Zjištění, zda už nejsme ve složce dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(basename "$SCRIPT_DIR")" = "installs" ]; then
  PARENT_DIR="$(dirname "$SCRIPT_DIR")"
else
  PARENT_DIR="$SCRIPT_DIR"
fi

if [ -d "$PARENT_DIR/kitty" ] && [ -d "$PARENT_DIR/zshrc" ]; then
  DOTFILES_DIR="$PARENT_DIR"
  echo -e "${GREEN}Spouštím přímo z klonované složky: $DOTFILES_DIR${NC}"
else
  DOTFILES_DIR="$HOME/$REPO_NAME"
  # Pokud složka neexistuje, naklonujeme ji
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}Klonuji repozitář z GitHubu ($GITHUB_USER)...${NC}"
    git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git" "$DOTFILES_DIR"
  else
    echo -e "${GREEN}Složka dotfiles již existuje. Aktualizuji...${NC}"
    cd "$DOTFILES_DIR" && git pull
  fi
fi

# Pokud nemáme stow, nainstalujeme ho (potřebujeme ho pro prolinkování)
if ! command -v stow &>/dev/null; then
  echo "Stow nenalezen. Instaluji..."
  sudo pacman -S --noconfirm stow
fi

# --- 3. Oh My Zsh a pluginy ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${BLUE}Instaluji Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo -e "${BLUE}Instaluji plugin zsh-syntax-highlighting...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo -e "${BLUE}Instaluji plugin zsh-autosuggestions...${NC}"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --- 4. Aplikace Configů (Stow) ---
echo -e "${BLUE}Propojuji dotfiles pomocí Stow...${NC}"

# Ujistíme se, že složka ~/.config existuje
mkdir -p "$HOME/.config"

cd "$DOTFILES_DIR"

# Seznam složek k propojení
STOW_DIRS=(
  "fastfetch"
  "lazygit"
  "yazi"
  "kitty"
  "btop"
  "starship"
  "zshrc"
)

# Funkce pro zálohování kolizních souborů/složek před spuštěním stow
backup_conflicts() {
  local dir="$1"
  find "$dir" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r item; do
    local rel="${item#$dir/}"
    if [ "$rel" = ".config" ]; then
      find "$item" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r subitem; do
        local subrel="${subitem#$dir/}"
        local target="$HOME/$subrel"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo -e "${BLUE}Zálohuji existující soubor/složku: $target -> $target.bak${NC}"
          mv "$target" "$target.bak"
        fi
      done
    else
      local target="$HOME/$rel"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${BLUE}Zálohuji existující soubor/složku: $target -> $target.bak${NC}"
        mv "$target" "$target.bak"
      fi
    fi
  done
}

for dir in "${STOW_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}Zálohuji konflikty a stowuji: $dir${NC}"
    backup_conflicts "$dir"
    stow --restow "$dir"
  else
    echo "Složka '$dir' v dotfiles neexistuje."
  fi
done

# --- 5. Přepnutí Shellu ---
if [ -f /usr/bin/zsh ]; then
  CURRENT_SHELL=$(basename "$SHELL")
  if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo -e "${BLUE}Měním výchozí shell na Zsh...${NC}"
    sudo chsh -s /usr/bin/zsh "$USER"
  fi
fi

echo -e "${GREEN}HOTOVO! Nastavení dotfiles a Stow dokončeno.${NC}"
