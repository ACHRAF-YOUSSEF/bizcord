#!/usr/bin/env bash
set -euo pipefail

# All secrets required — fail fast if any are missing
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"
: "${MEDIASOUP_API_SECRET:?MEDIASOUP_API_SECRET is required}"
: "${NODE_PUBLIC_IP:?NODE_PUBLIC_IP is required (mediasoup ANNOUNCED_IP)}"
: "${MAIL_USERNAME:?MAIL_USERNAME is required}"
: "${MAIL_PASSWORD:?MAIL_PASSWORD is required}"
: "${JWT_PRIVATE_KEY_FILE:?JWT_PRIVATE_KEY_FILE is required (path to jwtRS256.key)}"
: "${JWT_PUBLIC_KEY_FILE:?JWT_PUBLIC_KEY_FILE is required (path to jwtRS256.key.pub)}"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHART="$REPO_ROOT/k8s/bizcord"
NAMESPACE="bizcord-prod"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install bizcord "$CHART" \
  --namespace "$NAMESPACE" \
  -f "$CHART/values.yaml" \
  -f "$CHART/values.prod.yaml" \
  --set-file backend.secrets.jwtPrivateKey="$JWT_PRIVATE_KEY_FILE" \
  --set-file backend.secrets.jwtPublicKey="$JWT_PUBLIC_KEY_FILE" \
  --set backend.secrets.dbPassword="$DB_PASSWORD" \
  --set backend.secrets.mediasoupApiSecret="$MEDIASOUP_API_SECRET" \
  --set mediasoup.secrets.apiSecret="$MEDIASOUP_API_SECRET" \
  --set mediasoup.announcedIp="$NODE_PUBLIC_IP" \
  --set minio.secrets.rootPassword="$MINIO_ROOT_PASSWORD" \
  --set backend.secrets.mailUsername="$MAIL_USERNAME" \
  --set backend.secrets.mailPassword="$MAIL_PASSWORD" \
  --wait --timeout 10m

echo ""
echo "Prod deploy complete — $NAMESPACE"
