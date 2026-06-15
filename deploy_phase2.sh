#!/usr/bin/env bash
set -euo pipefail

# Patch the problem of routes

set -e
# Find the interface whose default route uses a private (10.x / 172.16-31 / 192.168) source
IFACE=$(ip -o -4 route show to default | awk '$9 ~ /^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)/ {print $5; exit}')
IFACE=${IFACE:-ens4}
sudo cat > /etc/netplan/99-ovh-docker-fix.yaml <<EOF
network:
  version: 2
  ethernets:
    ${IFACE}:
      dhcp4: true
      dhcp4-overrides:
        use-routes: false
EOF
sudo chmod 600 /etc/netplan/99-ovh-docker-fix.yaml
echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo netplan apply

cd "$HOME/activetigger/docker"

# Launch modes
declare -A MODES=(
  [prod]="-f docker-compose.yml -f docker-compose.nvidia.yml -f docker-compose.prod.yml"
  [dev]="-f docker-compose.yml -f docker-compose.nvidia.yml -f docker-compose.dev.yml"
  [dev-nogpu]="-f docker-compose.yml -f docker-compose.dev.yml"
)

MODE="${1:-}"
if [ -z "$MODE" ] || [ -z "${MODES[$MODE]+x}" ]; then
  echo "Usage: $0 <mode>"
  echo "Modes: ${!MODES[*]}"
  exit 1
fi

# GPU check only for GPU-based modes
if [[ "${MODES[$MODE]}" == *nvidia* ]]; then
  docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu24.04 nvidia-smi
fi

docker compose -p activetigger ${MODES[$MODE]} up -d