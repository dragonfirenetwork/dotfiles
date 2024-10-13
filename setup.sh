#!/bin/bash
set -e

# Dracula theme colors
RESTORE='\033[0m'
BLACK='\033[00;30m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
LBLACK='\033[01;30m'
LRED='\033[38;5;203m'  # Dracula Red
LGREEN='\033[38;5;83m' # Dracula Green
LYELLOW='\033[38;5;227m' # Dracula Yellow
LPURPLE='\033[38;5;141m' # Dracula Purple
LCYAN='\033[38;5;87m'    # Dracula Cyan
PINK='\033[38;5;205m'    # Dracula Pink
ORANGE='\033[38;5;215m'  # Dracula Orange
OVERWRITE='\e[1A\e[K'

# Emoji codes
CHECK_MARK="${LGREEN}\xE2\x9C\x94${RESTORE}"
X_MARK="${LRED}\xE2\x9C\x96${RESTORE}"
PIN="${PINK}\xF0\x9F\x93\x8C${RESTORE}"
CLOCK="${LCYAN}\xE2\x8C\x9B${RESTORE}"
ARROW="${LCYAN}\xE2\x96\xB6${RESTORE}"
BOOK="${LPURPLE}\xF0\x9F\x93\x8B${RESTORE}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${RESTORE}"
WARNING="${LRED}\xF0\x9F\x9A\xA8${RESTORE}"
RIGHT_ANGLE="${LGREEN}\xE2\x88\x9F${RESTORE}"

# Paths
DOTFILES_LOG="$HOME/.dotfiles.log"
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_GIT_REMOTE="https://github.com/dragonfirenetwork/dotfiles.git"
OS="$(uname -s)"

# Abort function for failure
abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast with a concise message when not using bash
if [ -z "${BASH_VERSION:-}" ]; then
  abort "${X_MARK} ${LRED}Bash is required to interpret this script.${RESTORE}"
fi

# _task colorize the given argument with spacing
function _task {
  if [[ $TASK != "" ]]; then
    printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}\n"
  fi
  TASK=$1
  printf "${LBLACK} [ ]  ${TASK} \n${LRED}"
}

# _cmd performs commands with error checking
function _cmd {
  if ! [[ -f $DOTFILES_LOG ]]; then
    touch $DOTFILES_LOG
  fi
  > $DOTFILES_LOG
  if eval "$1" 1> /dev/null 2> $DOTFILES_LOG; then
    return 0
  fi
  printf "${OVERWRITE}${LRED} [X]  ${TASK}${LRED}\n"
  while read -r line; do
    printf "      ${line}\n"
  done < $DOTFILES_LOG
  rm $DOTFILES_LOG
  exit 1
}

# Clear task
function _clear_task {
  TASK=""
}

# Mark task as done
function _task_done {
  printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}\n"
  _clear_task
}

# macOS Setup
macos_setup() {
  _task "Checking for Homebrew"
  if ! command -v brew &> /dev/null; then
    _cmd "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  fi
  _cmd "brew update && brew upgrade && brew cleanup"
  _task_done
}

# Check if Git is installed, if not install it
install_git() {
  _task "Checking for Git installation"
  if ! command -v git &> /dev/null; then
    _task "Installing Git"
    if [[ "$OS" == "Darwin" ]]; then
      _cmd "brew install git"
    elif [[ "$OS" == "Linux" ]]; then
      if command -v apt &> /dev/null; then
        _cmd "sudo apt update && sudo apt install -y git"
      elif command -v yum &> /dev/null; then
        _cmd "sudo yum install -y git"
      elif command -v dnf &> /dev/null; then
        _cmd "sudo dnf install -y git"
      elif command -v pacman &> /dev/null; then
        _cmd "sudo pacman -Syu --noconfirm git"
      elif command -v zypper &> /dev/null; then
        _cmd "sudo zypper install -y git"
      else
        abort "${X_MARK} ${LRED}No supported package manager found to install Git.${RESTORE}"
      fi
    else
      abort "${X_MARK} ${LRED}Unsupported operating system: $OS${RESTORE}"
    fi
  else
    _task_done
  fi
}

# Install Python, pip, and Ansible for different distros
install_dependencies() {
  _task "Installing dependencies"
  if [[ "$OS" == "Darwin" ]]; then
    _cmd "brew install ansible"
  elif [[ "$OS" == "Linux" ]]; then
    if grep -qEi "(debian|ubuntu|pop|mint)" /etc/*release; then
      _cmd "sudo apt update -y && sudo apt install -y python3 python3-pip software-properties-common"
      _cmd "sudo add-apt-repository --yes --update ppa:ansible/ansible"
      _cmd "sudo apt install -y ansible"
    elif grep -qEi "arch" /etc/*release; then
      _cmd "sudo pacman -Syu --noconfirm python ansible python-pip"
    elif grep -qEi "fedora" /etc/*release; then
      _cmd "sudo dnf install -y python3 python3-pip ansible"
    elif grep -qEi "centos|redhat" /etc/*release; then
      _cmd "sudo yum install -y python3 python3-pip ansible"
    else
      abort "${X_MARK} ${LRED}No supported package manager found to install Python, pip, and Ansible.${RESTORE}"
    fi
  else
    abort "${X_MARK} ${LRED}Unsupported operating system: $OS${RESTORE}"
  fi

  _cmd "pip3 install watchdog"
  _task_done
}

# Clone or update the dotfiles repository
clone_or_update_dotfiles() {
  _task "Cloning or updating dotfiles repository"
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    _cmd "git clone $DOTFILES_GIT_REMOTE $DOTFILES_DIR"
  else
    _cmd "cd $DOTFILES_DIR && git pull origin main"
  fi
  _task_done
}

# Install Ansible roles and collections from requirements.yml
install_ansible_requirements() {
  _task "Installing Ansible roles and collections from requirements.yml"
  if [[ -f "$DOTFILES_DIR/requirements.yml" ]]; then
    _cmd "ansible-galaxy install -r $DOTFILES_DIR/requirements.yml"
  else
    printf "${WARNING} ${LYELLOW}No requirements.yml found, skipping role and collection installation.${RESTORE}\n"
  fi
  _task_done
}

# Create the vault.secret file
create_vault_secret() {
  _task "Checking for vault.secret file"
  if [[ ! -f "$DOTFILES_DIR/vault.secret" ]]; then
    read -s -p "${LCYAN}Enter vault password: ${RESTORE}" vault
    echo "$vault" > "$DOTFILES_DIR/vault.secret"
    chmod 600 "$DOTFILES_DIR/vault.secret"
    printf "${CHECK_MARK} ${LGREEN}vault.secret created.${RESTORE}\n"
  else
    printf "${CHECK_MARK} ${LGREEN}vault.secret already exists, skipping.${RESTORE}\n"
  fi
  _task_done
}

# Function to prompt for role changes
prompt_for_role_changes() {
  _task "Prompting for role changes"
  printf "${LYELLOW}Would you like to make changes to the roles (packages) before proceeding?${RESTORE}\n"
  while true; do
    read -p "(Y/n): " CHANGE_ROLES
    if [[ "$CHANGE_ROLES" =~ ^[Yy]$ || -z "$CHANGE_ROLES" ]]; then
      printf "${LCYAN}To make changes, edit the following file:${RESTORE}\n"
      echo "$DOTFILES_DIR/group_vars/all.yml"
      echo
      printf "${LGREEN}To edit the file using 'vim' or 'nano', run:${RESTORE}\n"
      echo "vim $DOTFILES_DIR/group_vars/all.yml"
      echo "nano $DOTFILES_DIR/group_vars/all.yml"
      echo
      printf "${LYELLOW}Re-run this script after making changes, or run the playbook directly using:${RESTORE}\n"
      echo "ansible-playbook $DOTFILES_DIR/main.yml"
      echo "ansible-playbook $DOTFILES_DIR/main.yml --tag <package>"
      exit 0
    elif [[ "$CHANGE_ROLES" =~ ^[Nn]$ ]]; then
      printf "${CHECK_MARK} ${LGREEN}Proceeding with default roles...${RESTORE}\n"
      break
    else
      printf "${X_MARK} ${LRED}Invalid response. Please enter Y for Yes or N for No.${RESTORE}\n"
    fi
  done
  _task_done
}

# Main logic
install_git
install_dependencies
clone_or_update_dotfiles
install_ansible_requirements
create_vault_secret
prompt_for_role_changes

# Playbook run
_task "Running Ansible playbook"
_cmd "ansible-playbook $DOTFILES_DIR/main.yml"