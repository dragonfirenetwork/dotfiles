# Dragonfire Dotfiles

This repository contains the Ansible-based setup for configuring your development environment and installing key packages. 
It’s designed to be flexible and customizable, allowing you to pick and choose the components that best suit your needs.

## Download the 'setup.sh' script

If Git is not installed, you can still download the script directly using curl or wget. 
Open your terminal and enter one of the following commands:

Using ```curl```:
```
curl -O https://raw.githubusercontent.com/dragonfirenetwork/dotfiles/main/setup.sh
```

Using ```wget```:
```
wget https://raw.githubusercontent.com/dragonfirenetwork/dotfiles/main/setup.sh
```
Make the script executable:
```
chmod +x setup.sh
```

## Run the 'setup.sh' script

Now, run the ```setup.sh``` script to begin the setup process. This script will handle installing Git (if needed), cloning this repository, and installing all the necessary packages based on your configuration.

To execute the script:
```
./setup.sh
```

This will:

1. Install Git if not already available.
2. Clone the dotfiles repository.
3. Install Ansible and necessary roles/packages.
4. Run the Ansible playbook to set up your environment.

## Extras

The initial run of the ```setup.sh``` script will ask you if you want to proceed with the default installation or make changes. If you decide to make changes, you can do so below.

### Choosing Roles (Packages)

You can customize the packages that will be installed by editing the ```group_vars/all.yml``` file. 
Comment out any packages you don’t want to install.

To edit the file:
```
vim group_vars/all.yml

# Or use nano:
nano group_vars/all.yml
```

### Updating/Reseting Specific Roles (Packages)

You can also update or reset specific packages manually by providing specific tags to the Ansible playbook. Make sure the package is uncommented in the ```group_vars/all.yml``` file.

To update a package or reset a package to this default configuration run:
```
ansible-playbook <dotfiles_dir>/main.yml --tag <package>
```

For example, to upgrade/reset Alacritty:
```
cd $HOME/.dotfiles
ansible-playbook main.yml --tag alacritty
```