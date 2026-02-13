# Prints a color gradient to test truecolor support
colortest() {
  awk 'BEGIN{
      s=" "; s=s s s s s s s s;
      for (colnum = 0; colnum<77; colnum++) {
          r = 255-(colnum*255/76);
          g = (colnum*510/76);
          b = (colnum*255/76);
          if (g>255) g = 510 - g;
          printf "\033[48;2;%d;%d;%dm%s\033[0m", r,g,b,substr(s,colnum%8+1,1);
      }
      printf "\n";
  }'
}

# Show all apps manually installed by user (ONLY FOR LINUX MINT at the moment)
installed-apps() {
  gsettings get com.linuxmint.install installed-apps | tr ',' '\n' | tr -d "[]'" | sed 's/^ *//'
}

# Download entire website with wget
wgetsite() {
    if [ -z "$1" ]; then
        echo "Usage: wgetsite <url>"
        echo "Example: wgetsite https://example.com/docs/"
        return 1
    fi
    wget -r -np -k -p -E "$1"
    # -r = recursive
    # -np = no parent
    # -k = convert links to local files
    # -p = page requisites (download images, css, js, etc.)
    # -E = use .html extension
}

# ┌───────────────────────┐
# │    FZF and Ripgrep    │
# └───────────────────────┘

# fuzzy shell history
fsh() {
  eval "$(history | fzf | sed 's/ *[0-9]* *//')"
}

# search by file name
rgf() {
  rg --files --iglob "*$1*"
}

# ┌───────────────────────┐
# │          Git          │
# └───────────────────────┘

git-upstream() {
  git remote set-url origin "$1"
}

git-hardsync() {
	git fetch upstream
	git checkout main
	git reset --hard upstream/main
}

prune-branches() {
  # Capture pruned remote branches
  pruned_branches=$(git fetch -p 2>&1 | grep '\[deleted\]' | sed -E 's/.*-> origin\///')

  if [[ -z "$pruned_branches" ]]; then
      echo "No pruned branches. Nothing to do."
      exit 0
  fi

  echo "Remote branches pruned:"
  echo "$pruned_branches"
  echo

  # Loop through each pruned branch
  for pruned in $pruned_branches; do
      if git show-ref --verify --quiet "refs/heads/$pruned"; then
          read -p "Local branch '$pruned' matches a just-pruned remote. Delete? [y/N] " confirm
          if [[ $confirm == [yY] ]]; then
              git branch -D "$pruned"
          fi
      fi
  done
}

# ┌───────────────────────┐
# │         CI/CD         │
# └───────────────────────┘

diff-workflows() {
  BASE_DIR="$projects/.scripts/github_workflows" 
  TARGET_DIR="$(pwd)/.github/workflows"

  if diff -qr "$BASE_DIR" "$TARGET_DIR" > /dev/null; then
      echo "✅ No differences between $BASE_DIR and $TARGET_DIR"
      exit 0
  else
      echo "❌ Differences detected between $BASE_DIR and $TARGET_DIR"
      exit 1
  fi
}

# ┌───────────────────────┐
# │       Oh My Zsh       │
# └───────────────────────┘

# Turn Oh My Zsh plugins on or off and reload
my-plugins() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: my-plugins on|off <plugin-name>"
    return 1
  fi
  if [[ "$1" == "on" ]]; then
    omz plugin enable "$2"
    exec zsh
  elif [[ "$1" == "off" ]]; then
    omz plugin disable "$2"
    exec zsh
  else
    echo "Invalid option: $1. Choose on or off."
    return 1
  fi
}


# ┌───────────────────────┐
# │       Hardware        │
# └───────────────────────┘

# More flexible version
add-latency() {
    local iface=${1:-"unset"}
    local delay=${2:-100ms}

    if [[ "$iface" == "unset" ]]; then
        echo "Usage: add-latency <interface> <delay>"
        echo "Example: add-latency eth0 100ms"
        echo "Use show-interfaces to see available interfaces"
        return 1
    fi

    sudo tc qdisc add dev "$iface" root netem delay "$delay"
    echo "Added ${delay} latency to ${iface}"
}

remove-latency() {
    local iface=${1:-"unset"}

    if [[ "$iface" == "unset" ]]; then
        echo "Usage: remove-latency <interface>"
        echo "Use show-interfaces to see available interfaces"
        return 1
    fi
    sudo tc qdisc del dev "$iface" root 2>/dev/null && echo "Removed latency from ${iface}" || echo "No latency rules found on ${iface}"
}