#!/usr/bin/env bash
set -euo pipefail

# Drivers
sudo apt update && sudo apt upgrade -y
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers install

# Docker
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo apt install -y docker-compose-plugin
sudo usermod -aG docker "$USER"

# Docker GPU
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Clone
cd $HOME
if [ ! -d activetigger ]; then
  git clone https://github.com/activetigger/activetigger.git
fi
cd activetigger/docker
git checkout production 2>/dev/null || git checkout -b production


echo "Phase 1 done. Edit docker/docker.env now if needed, then reboot (sudo reboot) and run ./deploy_phase2.sh to run"