# Exports
if [ -f "/etc/doas.conf" ]; then
  export ROOT="doas"
elif [ -f "/usr/bin/sudo" ]; then
  export ROOT="sudo"
else
  echo "WARNING: Doas and sudo not found. Install doas or sudo!"
fi
export QT_QPA_PLATFORM="wayland"
export EDITOR="nvim"
export BROWSER="/usr/bin/librewolf"
export VISUAL="nvim"
export PATH="$PATH:$HOME/.bin:$HOME/.local/bin"

# Flatpak
if [ -f "/usr/bin/flatpak" ]; then
  export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share/applications"  
fi

# Android SDK
if [ -d "$HOME/Android/sdk/" ]; then
  export PATH="$PATH:$HOME/Android/sdk/"
fi

# Spicetify
if [ -d "$HOME/.spicetify/" ]; then
  export PATH="$PATH:$HOME/.spicetify"
fi

# Zsh/Posh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
plugins=(
  git
  )
POSH=agnoster
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)"

# Aliases
    # sdcard encrypt
    alias mount-sd="mountpoint-sdcrypt; $ROOT cryptsetup open /dev/sda3 sdcard-encrypted; $ROOT mount /dev/mapper/sdcard-encrypted /mnt/sdcard-encrypted"
    alias umount-sd="$ROOT umount /mnt/sdcard-encrypted; $ROOT cryptsetup close sdcard-encrypted; "

    # portage
    alias ins="$ROOT emerge -navq"
    alias sup="$ROOT emerge --sync; $ROOT emerge -avq --changed-use --newuse --update --deep @world"
    alias up="$ROOT emerge -avq --changed-use --newuse --update --deep @world"
    alias qsup="$ROOT emerge --sync; $ROOT emerge -av --changed-use --newuse --update --deep @world"
    alias qup="$ROOT emerge -av --changed-use --newuse --update --deep @world"
    alias mc="$ROOT nvim /etc/portage/make.conf"

    # basic (doas, ls, etc.)
    alias l="ls"
    alias la="ls -a"
    alias s="$ROOT"
    alias scp="$ROOT cp -r"
    alias svim="$ROOT nvim"
    alias catboys="cat"
    alias rm="$ROOT rm -rf"
    alias v="nvim"
    alias d="$ROOT"

    # Android Dev Stuff
    alias sync="repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags"
    alias b="make bacon -j$(nproc --all)"

    # git
    alias gcl="git clone -j$(nproc --all)"
    alias gad="git add"
    alias gcm="git commit -s -m"
    alias gra="git remote add"
    alias gpu="git push -u"
    alias gin="git init"
    alias gbr="git branch"
    alias gpl="git pull -j$(nproc --all)"
    alias gru="git remote update"
    alias gcp="git cherry-pick -s"
    alias gccp="git cherry-pick --continue"
    alias gst="git status"
    alias grm="git remote remove"
    alias gck="git checkout"
    alias grv="git revert -s"
    alias grs="git revert --skip"
    alias grb="git revert --abort"
    alias gcs="git cherry-pick --skip"
    alias grn="git revert --no-edit -S -s"
    alias gco="git commit -s"
    alias gca="git commit -s --amend"
    alias gmr="git merge -S --signoff --log"
    alias gms="git merge --skip"
    alias gma="git merge --abort"

    # zsh
    alias zshrc="$EDITOR ~/.zshrc"
    alias zsh="source ~/.zshrc"

# Commands
command_not_found_handler() {
	printf "%s%s?! Learn how to type dumbass fr\n" "$acc" "$0" >&2
  return 127
}

mountpoint-sdcrypt () {
 if [ ! -d "/mnt/sdcard-encrypted" ]; then
    "$ROOT" "mkdir -p /mnt/sdcard-encrypted"
    echo "mountpoint for sdcard-encrypted created"
 fi
}

# Startup
fastfetch

# Ccache
if [ -f "/usr/bin/ccache" ]; then
  export "USE_CCACHE=1"
  export "CCACHE_EXEC=/usr/bin/ccache"
  if [ ! -d "$HOME/.ccache" ]; then
    mkdir -p "$HOME/.ccache/"
    export CCACHE_DIR="/home/ksawlii/.ccache"  
  fi
else
  export "USE_CCACHE=0"
fi

# History
setopt auto_cd
setopt correct_all
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_save_no_dups
