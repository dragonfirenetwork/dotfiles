# Dragonfire Dotfiles

## MacOS Initial Tasks

Install the 'brew' package manager:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Linux (Debian) Initial Tasks

Update the system:

```
sudo apt update && sudo apt upgrade
```

Ensure 'curl' is installed:

```
curl --version
```

If it's not installed:

```
sudo apt install curl
```

## Windows Initial Tasks

Ensure that 'curl' is installed:

```
curl -V
```

## Download the 'setup' script

```
curl https://github.com/dragonfirenetwork/dotfiles/blob/main/scripts/setup.sh
```

Run the script.
