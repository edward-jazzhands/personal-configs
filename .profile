
# only if current shell session is bash and .bashrc exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# zsh sources this file and the .zshrc file automatically,
# so we don't need to do anything here.

# Add $HOME/.local/bin to the path
export PATH="$HOME/.local/bin:$PATH"

# Add $HOME/bin to the path
export PATH="$HOME/bin:$PATH"

if [ "$(uname)" = "Linux" ]; then
    echo "Running on Linux"
elif [ "$(uname)" = "Darwin" ]; then
    echo "Running on macOS"
fi

if [ -f /etc/debian_version ]; then
    echo "Debian-based system"
elif [ -f /etc/redhat-release ]; then
    echo "RedHat-based system"
fi