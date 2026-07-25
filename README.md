# ❄️ Dotfiles

> Personal configuration files for Arch-based Linux distributions (optimized for EndeavourOS).
> Managed with ❤️ using **GNU Stow**.

<p align="center">
  <img src="assets/preview-catppuccin.png" alt="System Showcase" width="95%" style="border-radius: 8px;" />
</p>

---

## 🚀 Quick Start (Automated Installation)

You can set up your environment using two separate scripts depending on your distribution:

### 1a. Install Applications (Arch Linux / EndeavourOS)
This script updates your system, installs `paru` if missing, and installs all required packages (browsers, media players, editors, terminal utilities):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/project-lbr/dotfiles/main/installs/install_apps.sh)"
```

### 1b. Install Applications (CachyOS)
This script is optimized for **CachyOS**. It pulls performance-optimized packages (like `zen-browser` and `librewolf`) directly from CachyOS repositories, installs `btrfs-assistant` instead of `timeshift` (which conflicts with CachyOS snapper support), and installs `paru`:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/project-lbr/dotfiles/main/installs/install_apps_cachyos.sh)"
```

### 2. Setup Dotfiles & GNU Stow (All Distributions)
This script clones/updates the repository, sets up Fish, backs up your existing configurations (renames them to `.bak`), links the configurations using GNU Stow, and sets your default shell to Fish:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/project-lbr/dotfiles/main/installs/setup_dotfiles.sh)"
```

---

## 🛠️ Manual Installation & Dependencies

If you prefer to configure things manually or want to pick only specific configs:

### 1. Install Core Dependencies
Make sure you have the core packages installed:
```bash
sudo pacman -S kitty starship fish stow git ttf-jetbrains-mono-nerd
```

### 2. Clone the Repository
Clone the repository to your home directory:
```bash
git clone https://github.com/project-lbr/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Deploy Configs with Stow
Use GNU Stow to symlink the configurations:
```bash
stow btop fastfetch kitty lazygit starship yazi fish
```

---

## 📦 What's Inside

This repository contains configurations for:

* **[Kitty](https://sw.kovidgoyal.net/kitty/)** - Fast, GPU-accelerated terminal emulator.
* **[Starship](https://starship.rs/)** - Blazing-fast, minimal, and customizable prompt.
* **[Fish](https://fishshell.com/)** - Smart and user-friendly command line shell.
* **[Fastfetch](https://github.com/fastfetch-cli/fastfetch)** - Elegant, fast system information display.
* **[Yazi](https://yazi-rs.github.io/)** - Blazing fast terminal file manager written in Rust.
* **[Btop](https://github.com/aristocratos/btop)** - Interactive system resources monitor.
* **[Lazygit](https://github.com/jesseduffield/lazygit)** - Simple terminal UI for git commands.

---

## 🔗 Useful Links & Addons
External add-ons used in this setup:
* [Kara](https://github.com/dhruv8sh/kara) - KDE Window Decoration theme.
* [Plasma 6 Window Title Applet](https://github.com/dhruv8sh/plasma6-window-title-applet) - Plasma 6 widget for displaying the active window title in the panel.
