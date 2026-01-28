# docker-userns.sh

# Create AI agent user
sudo useradd -u 1001 -s /bin/bash agent-1

# Set up subordinate UIDs/GIDs
echo "agent-1:1001:1" | sudo tee -a /etc/subuid
echo "agent-1:100000:65536" | sudo tee -a /etc/subuid
echo "agent-1:1001:1" | sudo tee -a /etc/subgid
echo "agent-1:100000:65536" | sudo tee -a /etc/subgid

# Create docker daemon config
sudo mkdir -p /etc/docker
echo '{
  "userns-remap": "agent-1:agent-1"
}' | sudo tee /etc/docker/daemon.json

# Restart docker
sudo systemctl restart docker

# Verify
docker info | grep -i userns
ls -la /var/lib/docker/ | grep 1001