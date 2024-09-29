#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define log file
LOG_FILE="$HOME/.mac_setup.log"

# Redirect all output to the log file
exec > >(tee -i "$LOG_FILE") 2>&1

echo "----- Mac Setup Script Started at $(date) -----"

# Function to handle cleanup on exit
cleanup() {
    echo "Cleaning up..."
    # Add any cleanup tasks here
}
trap cleanup EXIT INT TERM

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Xcode Command Line Tools silently
install_xcode_cli() {
    if xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools are already installed."
    else
        echo "Installing Xcode Command Line Tools..."
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//')
        if [ -n "$PROD" ]; then
            softwareupdate -i "$PROD" --verbose
            echo "Xcode Command Line Tools installation complete."
        else
            echo "No Command Line Tools update found."
            exit 1
        fi
    fi
}

# Function to install Homebrew
install_homebrew() {
    if command_exists brew; then
        echo "Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "Homebrew installation failed."; exit 1; }

        # Determine Homebrew installation path based on architecture
        ARCH=$(uname -m)
        if [ "$ARCH" = "arm64" ]; then
            BREW_PATH="/opt/homebrew/bin"
        else
            BREW_PATH="/usr/local/bin"
        fi

        # Detect shell and set profile file
        SHELL_NAME=$(basename "$SHELL")
        if [ "$SHELL_NAME" = "zsh" ]; then
            PROFILE_FILE="$HOME/.zshrc"
        else
            PROFILE_FILE="$HOME/.bash_profile"
        fi

        # Add Homebrew to PATH
        echo 'eval "$('"$BREW_PATH"'/brew shellenv)"' >> "$PROFILE_FILE"
        eval "$("$BREW_PATH"/brew shellenv)"
        echo "Homebrew installation complete."
    fi
}

# Function to update and upgrade Homebrew
update_homebrew() {
    echo "Updating Homebrew..."
    brew update || { echo "Failed to update Homebrew."; exit 1; }
    echo "Upgrading Homebrew packages..."
    brew upgrade || { echo "Failed to upgrade Homebrew packages."; exit 1; }
    brew upgrade --cask || { echo "Failed to upgrade Homebrew casks."; exit 1; }
    brew cleanup || { echo "Failed to clean up Homebrew."; exit 1; }
    echo "Homebrew packages upgraded and cleaned up."
}

# Function to install Stow
install_stow() {
    if brew list stow &>/dev/null; then
        echo "Stow is already installed."
    else
        echo "Installing Stow..."
        brew install stow || { echo "Failed to install Stow."; exit 1; }
        echo "Stow installation complete."
    fi
}

# Function to install Nerd Fonts
install_nerd_fonts() {
    echo "Installing Nerd Fonts..."
    NERD_FONTS=$(brew search --cask | grep -E '^font-.*-nerd-font$' || true)

    if [ -n "$NERD_FONTS" ]; then
        echo "Found the following Nerd Fonts to install:"
        echo "$NERD_FONTS"
        echo "$NERD_FONTS" | xargs -n1 brew install --cask || { echo "Failed to install some Nerd Fonts."; }
        echo "Nerd Fonts installation complete."
    else
        echo "No Nerd Fonts found to install."
    fi
}

# Function to clone or update dotfiles repository
setup_dotfiles() {
    DOTFILES_DIR="$HOME/.dotfiles"
    if [ -d "$DOTFILES_DIR" ]; then
        echo "Dotfiles repository already exists at $DOTFILES_DIR. Pulling latest changes..."
        cd "$DOTFILES_DIR"
        git pull || { echo "Failed to pull latest changes from dotfiles repository."; exit 1; }
    else
        echo "Cloning dotfiles repository..."
        git clone https://github.com/dragonfirenetwork/dotfiles.git "$DOTFILES_DIR" || { echo "Failed to clone dotfiles repository."; exit 1; }
    fi

    # Backup existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        echo "Backing up existing .zshrc to .zshrc.backup..."
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    fi

    # Remove the initial .zshrc file for the one about to be stowed
    rm -f "$HOME/.zshrc"

    # Stow the dotfiles
    echo "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    stow . || { echo "Failed to stow dotfiles."; exit 1; }
    echo "Dotfiles stowing complete."
}

# Function to setup SSH keys
setup_ssh() {
    echo "Setting up SSH keys..."
    SSH_KEY="p2XmGIVhheFb62VNJbFb" # Random name of your SSH key
    SSH_DIR="$HOME/.ssh"
    SOURCE_KEY_VAULT="$DOTFILES_DIR/vault/$SSH_KEY.vault"
    SOURCE_KEY_TEMP="$DOTFILES_DIR/vault/$SSH_KEY"
    DESTINATION_KEY="$SSH_DIR/dfn-openssh"

    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Check if the SSH key already exists
    if [ -f "$DESTINATION_KEY" ]; then
        echo "SSH key already exists at $DESTINATION_KEY. Skipping SSH setup."
        return
    fi

    # Check if ansible-vault is installed
    if ! command_exists ansible-vault; then
        echo "Ansible is not installed. Installing Ansible..."
        brew install ansible || { echo "Failed to install Ansible."; exit 1; }
    fi

    # Decrypt the SSH key using Ansible Vault
    if [ -f "$SOURCE_KEY_VAULT" ]; then
        echo "Decrypting SSH key..."
        # If using a vault password file, specify it here
        VAULT_PASSWORD_FILE="$DOTFILES_DIR/vault_password.txt"
        if [ -f "$VAULT_PASSWORD_FILE" ]; then
            ansible-vault decrypt "$SOURCE_KEY_VAULT" --output "$SOURCE_KEY_TEMP" --vault-password-file "$VAULT_PASSWORD_FILE" || { echo "Failed to decrypt SSH key."; exit 1; }
        else
            # Prompt for vault password if password file not found
            ansible-vault decrypt "$SOURCE_KEY_VAULT" --output "$SOURCE_KEY_TEMP" || { echo "Failed to decrypt SSH key."; exit 1; }
        fi

        chmod 600 "$SOURCE_KEY_TEMP"
        mv "$SOURCE_KEY_TEMP" "$DESTINATION_KEY" || { echo "Failed to move SSH key."; exit 1; }
        echo "SSH key setup complete."
    else
        echo "Encrypted SSH key not found at $SOURCE_KEY_VAULT. Skipping SSH setup."
    fi
}

# Function to set multiple wallpapers based on connected monitors
set_wallpapers() {
    echo "Setting wallpapers based on connected monitors..."

    WALLPAPER_DIR="$HOME/Wallpaper"

    # Define wallpaper files
    WALLPAPER1="$WALLPAPER_DIR/wallpaper1.jpg"
    WALLPAPER2="$WALLPAPER_DIR/wallpaper2.jpg"
    WALLPAPER3="$WALLPAPER_DIR/wallpaper3.jpg"

    # Array of wallpapers
    WALLPAPERS=("$WALLPAPER1" "$WALLPAPER2" "$WALLPAPER3")

    # Detect the number of connected displays
    DISPLAY_COUNT=$(system_profiler SPDisplaysDataType | awk '/spdisplays_display/{count++} END {print count}')

    echo "Detected $DISPLAY_COUNT display(s)."

    # Limit the display count to the number of available wallpapers
    AVAILABLE_WALLPAPERS=${#WALLPAPERS[@]}
    if [ "$DISPLAY_COUNT" -gt "$AVAILABLE_WALLPAPERS" ]; then
        echo "More displays detected ($DISPLAY_COUNT) than available wallpapers ($AVAILABLE_WALLPAPERS). Using $AVAILABLE_WALLPAPERS wallpapers."
        DISPLAY_COUNT="$AVAILABLE_WALLPAPERS"
    fi

    # Prepare the list of wallpapers to assign
    SELECTED_WALLPAPERS=()
    for (( i=0; i<DISPLAY_COUNT; i++ )); do
        WALLPAPER="${WALLPAPERS[i]}"
        if [ -f "$WALLPAPER" ]; then
            SELECTED_WALLPAPERS+=("$WALLPAPER")
        else
            echo "Wallpaper not found: $WALLPAPER. Skipping."
        fi
    done

    # Assign wallpapers using AppleScript
    if [ ${#SELECTED_WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers available to set."
        return
    fi

    # Convert array to AppleScript list format
    WALLPAPER_LIST=$(printf '"%s", ' "${SELECTED_WALLPAPERS[@]}" | sed 's/, $//')

    osascript <<EOF
tell application "System Events"
    set theDesktops to every desktop
    set wallpaperList to {${WALLPAPER_LIST}}
    repeat with i from 1 to count of theDesktops
        if i ≤ count of wallpaperList then
            set picture of item i of theDesktops to item i of wallpaperList
        end if
    end repeat
end tell
EOF

    echo "Wallpapers have been set successfully."
}

# Function to install and set Zsh on Intel Macs
install_set_zsh_intel() {
    ARCH=$(uname -m)
    if [ "$ARCH" != "arm64" ]; then
        echo "Detected Intel-based Mac."

        # Install Zsh via Homebrew if not installed
        if brew list zsh &>/dev/null; then
            echo "Zsh is already installed via Homebrew."
        else
            echo "Installing Zsh via Homebrew..."
            brew install zsh || { echo "Failed to install Zsh."; exit 1; }
            echo "Zsh installation complete."
        fi

        # Add Homebrew Zsh to /etc/shells if not already present
        BREW_ZSH_PATH=$(brew --prefix)/bin/zsh
        if ! grep -Fxq "$BREW_ZSH_PATH" /etc/shells; then
            echo "Adding $BREW_ZSH_PATH to /etc/shells."
            sudo sh -c "echo $BREW_ZSH_PATH >> /etc/shells"
        else
            echo "$BREW_ZSH_PATH is already in /etc/shells."
        fi

        # Change the default shell to Homebrew Zsh
        CURRENT_SHELL=$(basename "$SHELL")
        if [ "$CURRENT_SHELL" != "zsh" ]; then
            echo "Changing default shell to Zsh."
            chsh -s "$BREW_ZSH_PATH" || { echo "Failed to change default shell to Zsh."; exit 1; }
            echo "Default shell changed to Zsh."
        else
            echo "Default shell is already Zsh."
        fi
    else
        echo "Apple Silicon Mac detected. Skipping Zsh installation."
    fi
}

# Execute functions in order
install_xcode_cli
install_homebrew
update_homebrew
install_stow
install_nerd_fonts
setup_dotfiles
setup_ssh
install_set_zsh_intel
set_wallpapers

echo "Mac setup script completed successfully at $(date)!"
echo "Installed/Updated: Homebrew, Stow, Ansible, Nerd Fonts."
echo "Dotfiles have been stowed and SSH keys have been set up."