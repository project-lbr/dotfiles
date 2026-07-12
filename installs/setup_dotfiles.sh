#!/bin/bash

# --- 1. SETTINGS ---
GITHUB_USER="project-lbr"
REPO_NAME="dotfiles"

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

echo -e "${BLUE}Setting up dotfiles and Stow...${NC}"

# --- 2. Preparation (Git and Dotfiles) ---
echo -e "${BLUE}Checking if dotfiles exist...${NC}"

# If git is not installed, install it
if ! command -v git &>/dev/null; then
  echo "Git not found. Installing..."
  sudo pacman -S --noconfirm git
fi

# Check if we are already in the dotfiles folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(basename "$SCRIPT_DIR")" = "installs" ]; then
  PARENT_DIR="$(dirname "$SCRIPT_DIR")"
else
  PARENT_DIR="$SCRIPT_DIR"
fi

if [ -d "$PARENT_DIR/kitty" ] && [ -d "$PARENT_DIR/zshrc" ]; then
  DOTFILES_DIR="$PARENT_DIR"
  echo -e "${GREEN}Running directly from the cloned folder: $DOTFILES_DIR${NC}"
else
  DOTFILES_DIR="$HOME/$REPO_NAME"
  # If the folder does not exist, clone it
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}Cloning repository from GitHub ($GITHUB_USER)...${NC}"
    git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git" "$DOTFILES_DIR"
  else
    echo -e "${GREEN}Dotfiles folder already exists. Updating...${NC}"
    cd "$DOTFILES_DIR" && git pull
  fi
fi

# If stow is not installed, install it (needed for symlinking)
if ! command -v stow &>/dev/null; then
  echo "Stow not found. Installing..."
  sudo pacman -S --noconfirm stow
fi

# --- 3. Oh My Zsh and plugins ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${BLUE}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo -e "${BLUE}Installing zsh-syntax-highlighting plugin...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo -e "${BLUE}Installing zsh-autosuggestions plugin...${NC}"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --- 4. Applying Configs (Stow) ---
echo -e "${BLUE}Linking dotfiles using Stow...${NC}"

# Ensure the ~/.config directory exists
mkdir -p "$HOME/.config"

cd "$DOTFILES_DIR"

# List of folders to link
STOW_DIRS=(
  "fastfetch"
  "lazygit"
  "yazi"
  "kitty"
  "btop"
  "starship"
  "fish"
  "zshrc"
)

# Function to back up conflicting files/folders before running stow
backup_conflicts() {
  local dir="$1"
  find "$dir" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r item; do
    local rel="${item#$dir/}"
    if [ "$rel" = ".config" ]; then
      find "$item" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r subitem; do
        local subrel="${subitem#$dir/}"
        local target="$HOME/$subrel"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo -e "${BLUE}Backing up existing file/folder: $target -> $target.bak${NC}"
          mv "$target" "$target.bak"
        fi
      done
    else
      local target="$HOME/$rel"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${BLUE}Backing up existing file/folder: $target -> $target.bak${NC}"
        mv "$target" "$target.bak"
      fi
    fi
  done
}

for dir in "${STOW_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}Backing up conflicts and stowing: $dir${NC}"
    backup_conflicts "$dir"
    stow --restow "$dir"
  else
    echo "Folder '$dir' does not exist in dotfiles."
  fi
done

# --- 5. Switching Shell ---
if [ -f /usr/bin/fish ]; then
  CURRENT_SHELL=$(basename "$SHELL")
  if [ "$CURRENT_SHELL" != "fish" ]; then
    echo -e "${BLUE}Changing default shell to Fish...${NC}"
    sudo chsh -s /usr/bin/fish "$USER"
  fi
elif [ -f /usr/bin/zsh ]; then
  CURRENT_SHELL=$(basename "$SHELL")
  if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo -e "${BLUE}Changing default shell to Zsh...${NC}"
    sudo chsh -s /usr/bin/zsh "$USER"
  fi
fi

echo -e "${GREEN}DONE! Dotfiles and Stow setup completed.${NC}"
