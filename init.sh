#!/usr/bin/env bash

#! WARNING: This will overwrite existing files!
# Create symlinks to the dotfiles in the home directory

# Error handling setup
set -e
trap 'echo "Error occurred on line $LINENO" >&2' ERR
trap 'echo "Script interrupted" >&2; exit 1' INT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Absolute path to scripts: $SCRIPT_DIR"
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

echo "Done!"