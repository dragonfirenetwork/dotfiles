#!/bin/bash
set -e

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast with a concise message when not using bash
if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

# Set the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_GIT_REMOTE="https://github.com/dragonfirenetwork/dotfiles.git"
OS="$(uname -s)"

# Ansible playbook function
run_playbook() {
    echo "Beginning playbook run in 5 seconds..."
    sleep 5
    clear
    ansible-playbook "$DOTFILES_DIR/main.yml"
}

# If on MacOS
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "Installing the Homebrew package manager..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update && brew upgrade && brew cleanup
fi

# Check if Git is installed, if not install it
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing Git..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install git
    elif [[ "$OS" == "Linux" ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm git
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y git
        else
            echo "No supported package manager found to install Git."
            exit 1
        fi
    else
        echo "Unsupported operating system: $OS"
        exit 1
    fi
fi

# Associative array for package managers
declare -A package_managers
if [[ "$OS" == "Darwin" ]]; then
    package_managers=( ["brew"]="brew install ansible" )
elif [[ "$OS" == "Linux" ]]; then
    if grep -qEi "(debian|ubuntu)" /etc/*release; then
        # Specific logic for different Debian-based distros
        if grep -qEi "pop" /etc/*release; then
            package_managers=( ["apt"]="sudo apt install ansible -y" )  # Pop!_OS
        elif grep -qEi "ubuntu" /etc/*release; then
            package_managers=( ["apt"]="sudo apt update -y && sudo apt install software-properties-common -y && sudo add-apt-repository --yes --update ppa:ansible/ansible && sudo apt install ansible -y" )
        elif grep -qEi "debian" /etc/*release; then
            package_managers=( ["apt"]="UBUNTU_CODENAME=jammy && wget -O- \"https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367\" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg && echo \"deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu \$UBUNTU_CODENAME main\" | sudo tee /etc/apt/sources.list.d/ansible.list && sudo apt update && sudo apt install ansible -y" )
        fi
    else
        # Other Linux distros
        package_managers=(
            ["yum"]="sudo yum install -y ansible"
            ["dnf"]="sudo dnf install -y ansible"
            ["pacman"]="sudo pacman -Syu --noconfirm ansible"
            ["zypper"]="sudo zypper install -y ansible"
        )
    fi
else
    echo "Unsupported operating system: $OS"
    exit 1
fi

# Find the package manager and install Ansible
for manager in "${!package_managers[@]}"; do
    if command -v "$manager" &> /dev/null; then
        INSTALL_ANSIBLE="${package_managers[$manager]}"
        break
    fi
done

if [ -z "$INSTALL_ANSIBLE" ]; then
    echo "No supported package manager found."
    exit 1
fi

# Install Ansible if not installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible not found. Installing using $manager..."
    eval "$INSTALL_ANSIBLE"
else
    echo "Ansible is already installed, skipping."
fi

# Clone the dotfiles repository
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles repository into $DOTFILES_DIR..."
    git clone "$DOTFILES_GIT_REMOTE" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists. Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull origin main
    cd
fi

# Install Ansible requirements
if [[ -f "$DOTFILES_DIR/requirements.yml" ]]; then
    echo "Checking Ansible requirements..."
    ansible-galaxy install -r "$DOTFILES_DIR/requirements.yml"
else
    echo "No Ansible requirements found, skipping."
fi

# Create the vault.secret file
if [[ ! -f "$DOTFILES_DIR/vault.secret" ]]; then
    read -s -p "Enter vault password: " vault
    echo
    echo "$vault" > "$DOTFILES_DIR/vault.secret"
    chmod 600 "$DOTFILES_DIR/vault.secret"
else
    echo "vault.secret already exists, skipping."
fi

# Function to check the vault secret
check_vault_secret() {
    while true; do
        read -p "Is the vault.secret correct? (Y/n): " SECRET_CORRECT
        if [[ "$SECRET_CORRECT" =~ ^[Yy]$ || -z "$SECRET_CORRECT" ]]; then
            echo "Vault secret confirmed."
            break
        elif [[ "$SECRET_CORRECT" =~ ^[Nn]$ ]]; then
            read -s -p "Re-enter vault password: " vault
            echo
            echo "$vault" > "$DOTFILES_DIR/vault.secret"
            chmod 600 "$DOTFILES_DIR/vault.secret"
        else
            echo "Invalid response. Please enter Y for Yes or N for No."
        fi
    done
}

# Loop until valid Y or N is entered for vault check
while true; do
    read -p "Would you like to check the vault.secret now? (Y/n): " VAULT_CHECK
    if [[ "$VAULT_CHECK" =~ ^[YyNn]$ || -z "$VAULT_CHECK" ]]; then
        break
    else
        echo "Invalid response. Please enter Y for Yes or N for No."
    fi
done

# Vault check logic
if [[ "$VAULT_CHECK" =~ ^[Yy]$ || -z "$VAULT_CHECK" ]]; then
    while true; do
        read -p "Would you like to manually check it yourself (recommended), or display it here? (M/d): " CHECK_TYPE
        if [[ "$CHECK_TYPE" =~ ^[MmDd]$ || -z "$CHECK_TYPE" ]]; then
            if [[ "$CHECK_TYPE" =~ ^[Mm]$ || -z "$CHECK_TYPE" ]]; then
                clear
                echo "You can manually check the file located at: $DOTFILES_DIR/vault.secret"
                exit 0
            elif [[ "$CHECK_TYPE" =~ ^[Dd]$ ]]; then
                check_vault_secret
            fi
            break
        else
            echo "Invalid response. Please enter M for Manual or D for Display."
        fi
    done
else
    echo "Skipping vault.secret check."
fi

# Function to prompt for role changes
prompt_for_role_changes() {
    echo "Would you like to make changes to the roles (packages) before proceeding?"
    while true; do
        read -p "(Y/n): " CHANGE_ROLES
        if [[ "$CHANGE_ROLES" =~ ^[Yy]$ || -z "$CHANGE_ROLES" ]]; then
            echo
            echo "To make changes to the roles (packages) to be installed, please edit the following file:"
            echo "$DOTFILES_DIR/group_vars/all.yml"
            echo
            echo "You can comment out any roles you don't want to install."
            echo
            echo "To edit the file using 'vim', run:"
            echo "vim $DOTFILES_DIR/group_vars/all.yml"
            echo
            echo "To edit the file using 'nano', run:"
            echo "nano $DOTFILES_DIR/group_vars/all.yml"
            echo
            exit 0
        elif [[ "$CHANGE_ROLES" =~ ^[Nn]$ ]]; then
            echo "Proceeding with default roles..."
            break
        else
            echo "Invalid response. Please enter Y for Yes or N for No."
        fi
    done
}

# Ask user if they'd like to make changes to the roles (packages)
prompt_for_role_changes

# Now run the playbook
run_playbook