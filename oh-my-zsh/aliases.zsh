# Lazy shortcuts
alias cl="clear"
alias ssh-config="nano ~/.ssh/config"
alias pyactivate="source .venv/bin/activate"

if [ "$(hostname)" = "truenas" ]; then
    alias code-server-tty="sudo docker exec -it code-server zsh"
fi

# Check OS (using uname)
if [ "$(uname)" = "Linux" ]; then
    echo "Running on Linux"
elif [ "$(uname)" = "Darwin" ]; then
    echo "Running on macOS"
fi

# Alternative: check if specific OS files exist
if [ -f /etc/debian_version ]; then
    echo "Debian-based system"
elif [ -f /etc/redhat-release ]; then
    echo "RedHat-based system"
fi