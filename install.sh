#!/bin/bash
set -e

# Unset some variables
unset SKIPPED NOT_FOUND ROOT

# Commands (ig ;p)
ask_ny() {
  while true; do
    read -p "$1 (y/n): " ny
    case $ny in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
          * ) echo "Please answer y or n.";;
    esac
  done
}

command_checker() {
  command -v "$1" &>/dev/null
}

error() {
  echo "ERROR: $1" >&2
  exit 1
}

warning() {
  echo "WARNING: $1" >&2
}

info() {
  echo "INFO: $1" >&2
}

if [ "$EUID" -eq 0 ]; then
  error "This script should not be run as root. Please run it as a regular user."
fi

if [ -f "/etc/doas.conf" ] && "command_checker" "doas"; then
  ROOT="doas"
elif "command_checker" "sudo"; then
  ROOT="sudo"
else
  error "Doas and sudo not found. Install doas or sudo!"
fi

warning "Make sure you have $HOME/.config/ and .zsh* backup!"
sleep 2

if grep -q "gentoo" "/etc/os-release"; then
  echo ""
  info "Gentoo Linux detected"
  echo ""
  if ask_ny "Do you want to install dependencies (very recommended)?"; then 
    "$ROOT" emerge -navq eselect-repository
    "$ROOT" eselect repository enable librewolf kzd guru steam-overlay
    "$ROOT" emerge --sync
    "$ROOT" cp -rf "$(pwd)/gentoo/package.accept_keywords/" "/etc/portage/"
    "$ROOT" cp -rf "$(pwd)/gentoo/package.use/" "/etc/portage/"
    "$ROOT" emerge -navq \
            hyprland wlogout waybar rofi neovim xdg-desktop-portal swaybg \
            dev-python/pipx thunar kitty dev-perl/Gtk2 wl-clipboard swaylock \
            dev-perl/Gtk3 xcur2png nwg-look fastfetch zsh grim slurp satty wlroots xdg-desktop-portal-gtk xdg-desktop-portal-wlr
  else
    warning "Skipping dependencies installation"
    SKIPPED="1"
  fi
  if [ -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
    if ! grep -q "Exec=dbus-run-session Hyprland" /usr/share/wayland-sessions/hyprland.desktop; then
      echo ""
      info "Patching hyprland.desktop to run with dbus"
      "$ROOT" patch -p1 -d "/usr/share/wayland-sessions/" < "patches/0001-Run-hyprland-with-dbus.patch"
    fi
  else
    warn "/usr/share/wayland-sessions/hyprland.desktop not found. Skipping 0001-Run-hyprland-with-dbus.patch"
  fi

elif grep -q "arch" "/etc/os-release"; then
  echo ""
  info "Arch Linux detected"
  echo ""
  # Enable multilib if it's not already enabled
  if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    info "Enabling multilib repository..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | "$ROOT" tee -a /etc/pacman.conf
    "$ROOT" pacman -Syu
  fi
  if ! "command_checker" "yay"; then
    echo ""
    info "Yay not installed. Installing yay (AUR helper)..."
    "$ROOT" pacman -Syu --needed base-devel git
    git clone "https://aur.archlinux.org/yay.git" "$HOME/.yay"
    cd "$HOME/.yay"
    makepkg -si
    rm -rf "$HOME/.yay"
  fi
   
  echo ""
  if ask_ny "Do you want to install dependencies (very recommended)?"; then
    yay -Syu --noconfirm --needed \
    hyprland waybar rofi python-pipx kitty xdg-desktop-portal neovim \
    gtk2 gtk3 nwg-look fastfetch zsh grim satty xdg-desktop-portal-gtk swaybg thunar \
    xcur2png gsettings-qt slurp wlogout wl-clipboard xdg-desktop-portal-wlr
  else
    warning "Skipping dependencies installation"
    SKIPPED="1"
  fi
else
  error "Your distro is not supported"
fi

# Oh My Zsh
if [ ! "$SKIPPED" = "1" ]; then
  echo ""
  unset SKIPPED
fi
if [ ! -d "$HOME/.oh-my-zsh/" ]; then
  info "Oh My Zsh Not found. Installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &> /dev/null
fi
# Oh My Zsh Plugins
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions/" ]; then
  info "zsh-completions plugin not found. Installing..."
  git clone "https://github.com/zsh-users/zsh-completions" "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" &> /dev/null
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/" ]; then
  info "zsh-syntax-highlighting plugin not found. Installing..."
  git clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" &> /dev/null
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/" ]; then
  info "zsh-history-substring-search plugin not found. Installing..."
  git clone "https://github.com/zsh-users/zsh-history-substring-search" "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search" &> /dev/null
fi
# Oh My Posh
if ! "command_checker" "oh-my-posh"; then
  info "Oh My Posh Not Found. Installing..."
  if [ ! -d "$HOME/.local/bin/" ]; then
    mkdir -p "$HOME/.local/bin/"
  fi
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin/" &> /dev/null
  NOT_FOUND="1"
fi
if [ ! "$NOT_FOUND" = "1" ]; then
  echo ""
  unset NOT_FOUND
fi
echo "Copying dotfiles files"
sleep 1
if [ ! -d "$(pwd)/.config" ]; then
  mv "$(pwd)/configs" ".config"
fi
if [ -d "$(pwd)/.config" ]; then
  echo "Copying .config folder"
  cp -rf "$(pwd)/.config" "$HOME/"
else
  if [ -d "$(pwd)/.config" ]; then
    mv "$(pwd)/.config" "$(pwd)/configs"
  fi
  error ".config folder not found"
fi
if [ -f "$(pwd)/.config/zsh/zshrc" ]; then
  echo "Copying zshrc"
  cp -rf "$(pwd)/.config/zsh/zshrc" "$HOME/.zshrc"
else
  if [ -d "$(pwd)/.config" ]; then
    mv "$(pwd)/.config" "$(pwd)/configs"
  fi
  error "zshrc not found!"
fi
if [ -d "$(pwd)/.config" ]; then
  mv "$(pwd)/.config" "$(pwd)/configs"
fi
sleep 1

# Nerd Fonts
echo ""
if [ ! -d "$HOME/nerd-fonts/" ]; then
  if ask_ny "Do you want Nerd Fonts (Recommended) (8GB)?"; then
    git clone -j$(nproc --all) --depth=1 "https://github.com/ryanoasis/nerd-fonts.git" "$HOME/nerd-fonts"
    cd "$HOME/nerd-fonts/"
    ./install.sh
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mv MesloLGS\ NF\ * "$HOME/.local/share/fonts/NerdFonts/"
    rm -rf "$HOME/nerd-fonts"
  else
    warning "Skipping Nerd Fonts installation"
  fi
fi
sleep 1
echo "Done!"
exit 0
