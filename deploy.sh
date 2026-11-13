#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

echo "[deploy] Building and starting stack (waits for healthy services)..."
docker compose up -d --build --wait

echo "[deploy] sendportal_deploy logs:"
docker compose logs --no-color sendportal_deploy | tail -n 100

cid="$(docker compose ps -aq sendportal_deploy)"
if [ -z "$cid" ]; then
  echo "[deploy] sendportal_deploy container not found" >&2
  exit 1
fi

exit_code="$(docker inspect -f '{{.State.ExitCode}}' "$cid")"
if [ "$exit_code" != "0" ]; then
  echo "[deploy] sendportal_deploy failed with exit code ${exit_code}" >&2
  exit "$exit_code"
fi

echo "[deploy] Deployment complete"
