#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHART="$REPO_ROOT/k8s/bizcord"
NAMESPACE="bizcord"

KEYS_DIR="${KEYS_DIR:-$REPO_ROOT/bizcord-backend/keys/local-only}"

if [[ ! -f "$KEYS_DIR/jwtRS256.key" ]]; then
  echo "ERROR: JWT private key not found at $KEYS_DIR/jwtRS256.key"
  exit 1
fi

if [[ -z "${MEDIASOUP_ANNOUNCED_IP:-}" ]]; then
  # Auto-detect LAN IP as fallback
  MEDIASOUP_ANNOUNCED_IP="$(hostname -I | awk '{print $1}')"
  echo "INFO: MEDIASOUP_ANNOUNCED_IP not set, using detected LAN IP: $MEDIASOUP_ANNOUNCED_IP"
fi

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install bizcord "$CHART" \
  --namespace "$NAMESPACE" \
  -f "$CHART/values.yaml" \
  -f "$CHART/values.homelab.yaml" \
  --set-file backend.secrets.jwtPrivateKey="$KEYS_DIR/jwtRS256.key" \
  --set-file backend.secrets.jwtPublicKey="$KEYS_DIR/jwtRS256.key.pub" \
  --set backend.secrets.dbPassword="${DB_PASSWORD:-homelabpassword}" \
  --set backend.secrets.mediasoupApiSecret="${MEDIASOUP_API_SECRET:-homelab-mediasoup-secret}" \
  --set mediasoup.secrets.apiSecret="${MEDIASOUP_API_SECRET:-homelab-mediasoup-secret}" \
  --set mediasoup.announcedIp="$MEDIASOUP_ANNOUNCED_IP" \
  --set minio.secrets.rootPassword="${MINIO_ROOT_PASSWORD:-homelabpassword}" \
  --wait --timeout 5m

echo ""
echo "Homelab deploy complete."
echo "Add to /etc/hosts (or your DNS/Pi-hole):"
echo "  $MEDIASOUP_ANNOUNCED_IP  bizcord.local"
echo ""
echo "  App:     http://bizcord.local"
echo "  Mailpit: kubectl -n $NAMESPACE port-forward svc/mailpit 8025:8025"
