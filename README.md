# 🛠️ Dotfiles

A collection of configuration files to quickly bootstrap and set up any new **Linux** 🐧, **macOS** 🍎, or **Windows** 🪟 machine. This repository automates the setup process, ensuring a consistent and efficient environment across different operating systems.

## 📋 Table of Contents

- [✨ Features](#features)
- [📝 Prerequisites](#prerequisites)
- [🚀 Installation](#installation)
  - [🍎 macOS](#macos)
  - [🐧 Linux](#linux)
  - [🪟 Windows](#windows)
- [🎯 Usage](#usage)
- [📄 License](#license)

## ✨ Features

- **Cross-Platform Support**: Automates setup for macOS 🍎, Linux 🐧, and Windows 🪟.
- **Configuration Management**: Utilizes Ansible and GNU Stow for managing configurations.
- **Package Management**: Installs necessary packages using Homebrew (macOS) or other package managers.
- **Secure Setup**: Handles SSH key setup and encryption.
- **Customizable**: Easily extendable to include additional configurations and scripts.

## 📝 Prerequisites

### Common

- **Git**: Version control system.
- **Ansible**: Automation tool for configuration management.
- **GNU Stow**: Symlink farm manager for managing dotfiles.

### macOS Specific 🍎

- **Apple's Command Line Tools**: Required for Git and Homebrew.

### Linux Specific 🐧

- **Package Manager**: `apt`, `dnf`, or `pacman` depending on the distribution.

### Windows Specific 🪟

- **Git for Windows**: Includes Git Bash.
- **Chocolatey**: Package manager for Windows.
- **Windows Subsystem for Linux (WSL)** *(optional)*: For running Linux distributions on Windows.

## 🚀 Installation

### 🍎 macOS

#### Introduction:

This section guides you through bootstrapping a new macOS machine using the dotfiles repository.

1. **Install Apple's Command Line Tools**

    ```bash
    xcode-select --install
    ```

2. **Install Homebrew**

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

3. **Install Ansible and Stow**

    ```bash
    brew install ansible stow
    ```

4. **Clone the Dotfiles Repository**

    ```bash
    git clone git@github.com:dragonfirenetwork/dotfiles.git ~/.dotfiles
    ```

5. **Run Ansible Playbook**

    ```bash
    ansible-playbook ~/.dotfiles/playbook.yml
    ```

6. **Create Symlinks Using Stow**

    ```bash
    stow -v -t ~ bash git vim zsh
    ```

7. **Install Software from Brewfile**

    ```bash
    brew bundle --file ~/.dotfiles/programs/Brewfile
    ```

### 🐧 Linux

#### Introduction:

This section guides you through bootstrapping a new Linux machine using the dotfiles repository.

1. **Install Git, Ansible, and Stow**

    For Debian/Ubuntu-based distributions:

    ```bash
    sudo apt update
    sudo apt install -y git ansible stow
    ```

    For Fedora:

    ```bash
    sudo dnf install -y git ansible stow
    ```

    For Arch Linux:

    ```bash
    sudo pacman -S --noconfirm git ansible stow
    ```

2. **Clone the Dotfiles Repository**

    ```bash
    git clone git@github.com:dragonfirenetwork/dotfiles.git ~/.dotfiles
    ```

3. **Run Ansible Playbook**

    ```bash
    ansible-playbook ~/.dotfiles/playbook.yml
    ```

4. **Create Symlinks Using Stow**

    ```bash
    stow -v -t ~ bash git vim zsh
    ```

5. **Install Packages from Package Manager**

    *(Adjust the commands based on your distribution)*

    For Debian/Ubuntu:

    ```bash
    sudo apt install -y $(cat ~/.dotfiles/programs/apt-packages.txt)
    ```

    For Fedora:

    ```bash
    sudo dnf install -y $(cat ~/.dotfiles/programs/dnf-packages.txt)
    ```

    For Arch Linux:

    ```bash
    sudo pacman -S --noconfirm $(cat ~/.dotfiles/programs/pacman-packages.txt)
    ```

### 🪟 Windows

#### Introduction:

This section guides you through bootstrapping a new Windows machine using the dotfiles repository.

1. **Install Git for Windows**

    Download and install from [Git for Windows](https://gitforwindows.org/).

2. **Install Chocolatey**

    Open PowerShell as Administrator and run:

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    ```

3. **Install Ansible and Stow**

    Ansible is not natively supported on Windows, so it's recommended to use WSL.

    - **Install WSL**:

        ```powershell
        wsl --install
        ```

    - **Set Up Linux Distribution**: Choose a preferred distribution from the Microsoft Store (e.g., Ubuntu).

    - **Install Ansible and Stow in WSL**:

        ```bash
        sudo apt update
        sudo apt install -y git ansible stow
        ```

4. **Clone the Dotfiles Repository in WSL**

    ```bash
    git clone git@github.com:dragonfirenetwork/dotfiles.git ~/.dotfiles
    ```

5. **Run Ansible Playbook**

    ```bash
    ansible-playbook ~/.dotfiles/playbook.yml
    ```

6. **Create Symlinks Using Stow**

    ```bash
    stow -v -t ~ bash git vim zsh
    ```

7. **Install Software from Chocolatey**

    ```powershell
    choco install <package-name>
    ```

    *(Alternatively, manage Windows packages via Ansible within WSL)*

## 🎯 Usage

After installation, your environment should be set up with your preferred configurations. You can further customize and extend the dotfiles by modifying the repository and rerunning the Ansible playbook.

## 📄 License

This project is licensed under the [MIT License](LICENSE).