#!/bin/bash

set -e

# Create AI agent user (only if it doesn't exist)
if ! id -u agent-1 &>/dev/null; then
    echo "Creating user agent-1..."
    sudo useradd -u 1001 -s /bin/bash agent-1
else
    echo "User agent-1 already exists, skipping..."
fi

# Set up subordinate UIDs (only if not already present)
if ! grep -q "^agent-1:1001:1$" /etc/subuid 2>/dev/null; then
    echo "Adding agent-1:1001:1 to /etc/subuid..."
    echo "agent-1:1001:1" | sudo tee -a /etc/subuid
else
    echo "Entry agent-1:1001:1 already exists in /etc/subuid, skipping..."
fi

if ! grep -q "^agent-1:100000:65536$" /etc/subuid 2>/dev/null; then
    echo "Adding agent-1:100000:65536 to /etc/subuid..."
    echo "agent-1:100000:65536" | sudo tee -a /etc/subuid
else
    echo "Entry agent-1:100000:65536 already exists in /etc/subuid, skipping..."
fi

# Set up subordinate GIDs (only if not already present)
if ! grep -q "^agent-1:1001:1$" /etc/subgid 2>/dev/null; then
    echo "Adding agent-1:1001:1 to /etc/subgid..."
    echo "agent-1:1001:1" | sudo tee -a /etc/subgid
else
    echo "Entry agent-1:1001:1 already exists in /etc/subgid, skipping..."
fi

if ! grep -q "^agent-1:100000:65536$" /etc/subgid 2>/dev/null; then
    echo "Adding agent-1:100000:65536 to /etc/subgid..."
    echo "agent-1:100000:65536" | sudo tee -a /etc/subgid
else
    echo "Entry agent-1:100000:65536 already exists in /etc/subgid, skipping..."
fi

# Create docker daemon config (only if it doesn't exist or doesn't have the right config)
sudo mkdir -p /etc/docker

DOCKER_CONFIG='{
  "userns-remap": "agent-1:agent-1"
}'

if [ ! -f /etc/docker/daemon.json ]; then
    echo "Creating /etc/docker/daemon.json..."
    echo "$DOCKER_CONFIG" | sudo tee /etc/docker/daemon.json
elif ! grep -q '"userns-remap".*"agent-1:agent-1"' /etc/docker/daemon.json 2>/dev/null; then
    echo "Warning: /etc/docker/daemon.json exists but doesn't contain the expected userns-remap configuration."
    echo "You may need to manually merge configurations."
else
    echo "/etc/docker/daemon.json already configured correctly, skipping..."
fi

echo "Setup complete!"