#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHART="$REPO_ROOT/k8s/bizcord"
NAMESPACE="bizcord-dev"

# Default: look for keys in the backend submodule's local-only dir
KEYS_DIR="${KEYS_DIR:-$REPO_ROOT/bizcord-backend/keys/local-only}"

if [[ ! -f "$KEYS_DIR/jwtRS256.key" ]]; then
  echo "ERROR: JWT private key not found at $KEYS_DIR/jwtRS256.key"
  echo "       Generate with: cd bizcord-backend && openssl genrsa -out keys/local-only/jwtRS256.key 4096"
  exit 1
fi

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install bizcord "$CHART" \
  --namespace "$NAMESPACE" \
  -f "$CHART/values.yaml" \
  -f "$CHART/values.dev.yaml" \
  --set-file backend.secrets.jwtPrivateKey="$KEYS_DIR/jwtRS256.key" \
  --set-file backend.secrets.jwtPublicKey="$KEYS_DIR/jwtRS256.key.pub" \
  --set backend.secrets.dbPassword="${DB_PASSWORD:-devpassword}" \
  --set mediasoup.announcedIp="${MEDIASOUP_ANNOUNCED_IP:-127.0.0.1}" \
  --wait --timeout 5m

echo ""
echo "Deploy complete. Access the app:"
echo "  kubectl -n $NAMESPACE port-forward svc/bizcord-frontend 8080:8080"
echo "  Mailpit UI: kubectl -n $NAMESPACE port-forward svc/mailpit 8025:8025"
