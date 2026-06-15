#!/usr/bin/env bash
set -euo pipefail

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