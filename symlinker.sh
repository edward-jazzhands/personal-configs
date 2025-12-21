#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Error handling setup
set -e
trap 'echo "Error occurred on line $LINENO" >&2' ERR
trap 'printf "    ${RED}Script interrupted${NC}\n" >&2; exit 1' INT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo "#===================================================================#"
echo "                Symlink creator script"
echo ""
printf "${RED}WARNING: Symlinks will overwrite existing .bashrc and other files.${NC} \n"

while true; do
    printf "${BLUE}Do you want to symlink your dotfiles in $HOME?${NC} \n"
    printf "(y/n[default]):"
    read -p " " answer1
    
    if [[ -z "$answer1" ]] || [[ "$answer1" =~ ^[YyNn]$ ]]; then
        break
    fi
    echo "Invalid input. Please enter y, n, or leave blank for no."
done


# we wouldn't be here if the answer was not y, n, or blank
if [[ "$answer1" =~ ^[Yy]$ ]]; then
    echo "Absolute path to configs dir: $SCRIPT_DIR"
    echo "Creating symlinks in $HOME"

    if output=$(ln -sf "$SCRIPT_DIR/.bashrc" ~/.bashrc 2>&1); then
        echo "$SCRIPT_DIR/.bashrc symlinked to $HOME/.bashrc"
    else
        echo "Error: $output"
    fi

    if output=$(ln -sf "$SCRIPT_DIR/.gitconfig" ~/.gitconfig 2>&1); then
        echo "$SCRIPT_DIR/.gitconfig symlinked to $HOME/.gitconfig"
    else
        echo "Error: $output"
    fi
    
    if output=$(ln -sf "$SCRIPT_DIR/.gitignore_global" ~/.gitignore_global 2>&1); then
        echo "$SCRIPT_DIR/.gitignore_global symlinked to $HOME/.gitignore_global"
    else
        echo "Error: $output"
    fi
    
    if output=$(ln -sf "$SCRIPT_DIR/.justfile" ~/.justfile 2>&1); then
        echo "$SCRIPT_DIR/.justfile symlinked to $HOME/.justfile"
    else
        echo "Error: $output"
    fi

    if output=$(ln -sf "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf 2>&1); then
        echo "$SCRIPT_DIR/.tmux.conf symlinked to $HOME/.tmux.conf"
    else
        echo "Error: $output"
    fi

    echo "Done creating symlinks in home directory"
else
    echo "Symlinks not created"
fi

echo ""


while true; do
    printf "${BLUE}Do you want to mount TrueNAS SMB shares (on tailnet)?${NC}\n"
    printf "This will symlink a .mount OR .automount file to /etc/systemd/system/ \n"
    printf "(y/n[default]):"
    read -p " " answer2
 
    if [[ -z "$answer2" ]] || [[ "$answer2" =~ ^[YyNn]$ ]]; then
        break
    fi
    echo "Invalid input. Please enter y, n, or leave blank for no."
done


if [[ "$answer2" =~ ^[Yy]$ ]]; then

    while true; do
        echo "Mount at boot, or mount lazily/automount (when you access the SMB share)?"
        printf "(b/l[default]):"
        read -p " " answer3
    
        if [[ "$answer3" =~ ^[BbLl]$ ]]; then
            break
        fi
        echo "Invalid input. Please enter b(oot), or l(azily)."
    done

    if [[ "$answer3" =~ ^[Bb]$ ]]; then

        echo "Configuring for mount at boot."
        echo "Attempting to disable automount if enabled"
        if output=$(sudo systemctl disable mnt-truenas\\x2dtailnet-brents\\x2ddata.automount 2>&1); then
            echo "Success: $output"
        else
            if echo "$output" | grep -q "automount does not exist"; then
                echo "Automount not found, nothing to disable"
            else
                echo "Error: $output"
            fi
        fi

        echo "Creating symlink and enabling mount at boot"
        if output=$(sudo ln -sf "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.mount" /etc/systemd/system/ 2>&1); then
            echo "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.mount symlinked to /etc/systemd/system/"
        else
            echo "Error: $output"
        fi

        if output=$(sudo systemctl enable mnt-truenas\\x2dtailnet-brents\\x2ddata.mount 2>&1); then
            printf "${GREEN}Success ${NC}"
            if [[ -n "$output" ]]; then
                echo ": $output"
            else
                echo ""
            fi
        else
            echo "$output"
        fi

    # if answer not Bb, then must be Ll. Only 2 options allowed.
    else  
        echo "Configuring for mount lazily (automount)."
        echo "Attempting to disable mount at boot if enabled"
        if output=$(sudo systemctl disable mnt-truenas\\x2dtailnet-brents\\x2ddata.mount 2>&1); then
            echo "Success: $output"
        else
            if echo "$output" | grep -q "x2ddata.mount does not exist"; then
                echo "Mount at boot not found, nothing to disable"
            else
                echo "Error: $output"
            fi
        fi

        echo "Creating both symlinks, enabling only automount"
        if output=$(sudo ln -sf "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.mount" /etc/systemd/system/ 2>&1); then
            echo "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.mount symlinked to /etc/systemd/system/"
        else
            echo "Error: $output"
        fi

        if output=$(sudo ln -sf "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.automount" /etc/systemd/system/ 2>&1); then
            echo "$SCRIPT_DIR/systemd/mnt-truenas\\x2dtailnet-brents\\x2ddata.automount symlinked to /etc/systemd/system/"
        else
            echo "Error: $output"
        fi
        
        if output=$(sudo systemctl enable mnt-truenas\\x2dtailnet-brents\\x2ddata.automount 2>&1); then
            printf "${GREEN}Success ${NC}"
            if [[ -n "$output" ]]; then
                echo ": $output"
            else
                echo ""
            fi
        else
            echo "$output"
        fi
    fi

    echo "SMB mount configured. Will be available after reboot."
else
    echo "SMB .mount files not symlinked"
fi
