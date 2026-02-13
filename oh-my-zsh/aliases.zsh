# Lazy shortcuts
alias cl="clear"
alias ssh-config="nano ~/.ssh/config"
alias pyactivate="source .venv/bin/activate"

alias show-interfaces="ip link show"

# This is to view artificially added latency:
alias show-latency="tc qdisc show"

if [ "$(hostname)" = "truenas" ]; then
    alias code-server-tty="sudo docker exec -it code-server zsh"
fi

