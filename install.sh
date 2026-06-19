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

echo -e "${BLUE}Začínám instalaci tvého systému...${NC}"

# --- 2. Příprava (Git a Dotfiles) ---
echo -e "${BLUE}Kontroluji existenci dotfiles...${NC}"

# Pokud nemáme git, nainstalujeme ho
if ! command -v git &>/dev/null; then
  echo "Git nenalezen. Instaluji..."
  sudo pacman -S --noconfirm git
fi

# Zjištění, zda už nejsme ve složce dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/kitty" ] && [ -d "$SCRIPT_DIR/zshrc" ]; then
  DOTFILES_DIR="$SCRIPT_DIR"
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

# --- 3. SEZNAM BALÍČKŮ (Tuxmate) ---
PKGS=(
  # Internet a Komunikace
  "zen-browser-bin" "discord" "thunderbird" "tailscale"
  "localsend-bin" "filezilla" "bitwarden" "obsidian" "librewolf-bin"

  # Média a Kancelář
  "vlc" "spotify" "onlyoffice-bin" "okular" "obs-studio" "droidcam" "freecad"

  # Editory a Vývoj
  "code" "neovim" "micro" "git" "lazygit" "antigravity"

  # Terminál a Shell
  "kitty" "zsh" "starship" "fastfetch" "btop" "yazi" "bat" "fzf"
  "zoxide" "tldr" "curl" "fd"

  # Systémové nástroje
  "timeshift" "flameshot" "stow" "syncthing"
)

# --- 4. Aktualizace a Instalace ---
echo -e "${BLUE}Aktualizuji systém...${NC}"
sudo pacman -Syu --noconfirm

# Automatická instalace yay, pokud chybí
if ! command -v yay &>/dev/null; then
  echo -e "${BLUE}'yay' nebyl nalezen. Instaluji 'yay-bin' z AUR...${NC}"
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin
  makepkg -si --noconfirm
  cd - &>/dev/null
  rm -rf /tmp/yay-bin
fi

echo -e "${BLUE}Instaluji balíčky pomocí yay...${NC}"
yay -S --needed --noconfirm "${PKGS[@]}"

# --- 4.5 Oh My Zsh a pluginy ---
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

# --- 5. Aplikace Configů (Stow) ---
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
  # Hledáme soubory/složky přímo v kořenu stow složky (např. .zshrc)
  find "$dir" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r item; do
    local rel="${item#$dir/}"
    if [ "$rel" = ".config" ]; then
      # Pro .config jdeme o úroveň hlouběji (např. .config/kitty, .config/starship.toml)
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
  sudo chsh -s /usr/bin/zsh "$USER"
fi

echo -e "${GREEN}HOTOVO! Restartuj terminál (nebo PC).${NC}"
