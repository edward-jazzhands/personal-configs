#!/bin/bash

set -e

# Create AI agent user
if id -u agent-1 &>/dev/null; then
    echo "User agent-1 already exists, skipping..."
else
    echo "Creating user agent-1..."
    sudo useradd -u 1001 -s /bin/bash agent-1
fi

# Create docker daemon config
DOCKER_CONFIG='{
  "userns-remap": "agent-1:agent-1"
}'

# Ensure /etc/docker exists (in case docker isn't installed yet)
sudo mkdir -p /etc/docker

if [ ! -f /etc/docker/daemon.json ]; then
    echo "Creating /etc/docker/daemon.json..."
    echo "$DOCKER_CONFIG" | sudo tee /etc/docker/daemon.json
elif ! grep -q '"userns-remap".*"agent-1:agent-1"' /etc/docker/daemon.json; then
    echo "Warning: /etc/docker/daemon.json exists but doesn't contain the expected userns-remap configuration."
    echo "You may need to manually merge configurations."
else
    echo "/etc/docker/daemon.json already configured correctly, skipping..."
fi

# Set up subordinate UIDs
tmp1=$(mktemp)
grep -v -e '^agent-1:' -e '^# Container' /etc/subgid > "$tmp1"
cat >> "$tmp1" <<'EOF'

# Container UID 0 (root) -> Host UID 1001 (agent-1)
agent-1:1001:1
# Container UID 1 -> Host UID 1000 (brent)
agent-1:1000:1
# Container UIDs 2-65535 -> Host UIDs 165536-231070
agent-1:165536:65535
EOF

sudo cp "$tmp1" /etc/subuid
rm "$tmp1"

# Set up subordinate GIDs
tmp2=$(mktemp)
grep -v -e '^agent-1:' -e '^# Container' /etc/subgid > "$tmp2"
cat >> "$tmp2" <<'EOF'

# Container UID 0 (root) -> Host UID 1001 (agent-1)
agent-1:1001:1
# Container UID 1 -> Host UID 1000 (brent)
agent-1:1000:1
# Container UIDs 2-65535 -> Host UIDs 165536-231070
agent-1:165536:65535
EOF

sudo cp "$tmp2" /etc/subgid
rm "$tmp2"


echo "Docker UserNS setup complete"