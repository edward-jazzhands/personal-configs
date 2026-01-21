# Ensure bin exists
mkdir -p "$HOME/.local/bin"

# Oh My Zsh (Requires Zsh)
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

# Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Just
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"

# FZF
curl -L https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_amd64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"

# Tmux
curl -L https://github.com/tmux/tmux-builds/releases/download/v3.6a/tmux-3.6a-linux-x86_64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"