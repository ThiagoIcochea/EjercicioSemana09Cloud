#!/usr/bin/env bash
# Prueba de punta a punta con Docker:
#   1. construye la imagen de la app
#   2. Terraform crea la flota de 32 "VMs" (contenedores)
#   3. verifica que las 32 estén sanas y respondan por HTTP
#   4. destruye todo (salvo KEEP=1)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT/terraform/environments/local-docker"
IMAGE="semana09-app:local"
EXPECTED="${EXPECTED_VMS:-32}"

cleanup() {
  if [[ "${KEEP:-0}" != "1" ]]; then
    echo "==> Destruyendo la flota"
    terraform -chdir="$TF_DIR" destroy -auto-approve -input=false >/dev/null
  fi
}

echo "==> Construyendo imagen $IMAGE"
docker build -t "$IMAGE" "$ROOT/app"

echo "==> terraform apply (local-docker)"
terraform -chdir="$TF_DIR" init -input=false
trap cleanup EXIT
terraform -chdir="$TF_DIR" apply -auto-approve -input=false

count="$(terraform -chdir="$TF_DIR" output -raw vm_count)"
echo "==> Terraform reporta $count VMs"
[[ "$count" == "$EXPECTED" ]] || { echo "ERROR: se esperaban $EXPECTED"; exit 1; }

echo "==> Esperando healthchecks"
for _ in $(seq 1 30); do
  healthy="$(docker ps --filter label=fleet=semana09-local --filter health=healthy -q | wc -l)"
  [[ "$healthy" -ge "$EXPECTED" ]] && break
  sleep 2
done
echo "    contenedores sanos: $healthy/$EXPECTED"
[[ "$healthy" -ge "$EXPECTED" ]] || { docker ps -a --filter label=fleet=semana09-local; exit 1; }

echo "==> Probando cada endpoint"
fails=0
while read -r name url; do
  body="$(curl -fsS "$url/")" || { echo "  FALLA $name"; fails=$((fails + 1)); continue; }
  role="$(python3 -c 'import json,sys;print(json.load(sys.stdin)["role"])' <<<"$body")"
  printf '  OK %-10s rol=%s\n' "$name" "$role"
done < <(terraform -chdir="$TF_DIR" output -json endpoints | python3 -c 'import json,sys;[print(k,v) for k,v in sorted(json.load(sys.stdin).items())]')

[[ "$fails" -eq 0 ]] || { echo "ERROR: $fails endpoints fallaron"; exit 1; }
echo "==> Todo OK: $EXPECTED VMs en Docker respondiendo"
