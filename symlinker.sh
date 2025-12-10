#!/bin/bash

#! WARNING: This will overwrite existing files!

# Error handling setup
set -e
trap 'echo "Error occurred on line $LINENO" >&2' ERR
trap 'printf "    \033[0;31mScript interrupted\033[0m\n" >&2; exit 1' INT

printf "\033[0;31mWARNING\033[0m: Symlinks will overwrite existing .bashrc and other files!\n"
read -p "Are you sure you want to symlink your dotfiles? (y[default]/n): " answer1

create_symlinks() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    echo "Absolute path to configs dir: $SCRIPT_DIR"
    echo "Creating symlinks in $HOME"

    ln -sf "$SCRIPT_DIR/.bashrc" ~/.bashrc
    echo "Created ~/.bashrc"
    ln -sf "$SCRIPT_DIR/.gitconfig" ~/.gitconfig
    echo "Created ~/.gitconfig"
    ln -sf "$SCRIPT_DIR/.gitignore_global" ~/.gitignore_global
    echo "Created ~/.gitignore_global"
    ln -sf "$SCRIPT_DIR/.justfile" ~/.justfile
    echo "Created ~/.justfile"
    ln -sf "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
    echo "Created ~/.tmux.conf"

    echo "Done creating symlinks"
}

if [[ "$answer1" =~ ^[Yy]$ ]]; then
    create_symlinks
elif [[ "$answer1" =~ ^[Nn]$ ]]; then
    echo "Symlinks not created"
elif [[ -z "$answer1" ]]; then
    create_symlinks
else
    echo "Invalid input. Please enter y, n, or leave blank for yes."
fi
