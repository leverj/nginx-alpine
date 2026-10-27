#!/usr/bin/env bash
# Build and publish using an authenticated Docker configuration supplied by the
# caller. This script never looks up credentials or performs a registry login.
# Optional IMAGE_TAG overrides <nginx>-alpine<alpine>-<UTC YYYYMMDD>.

set -euo pipefail

# Build context is the repo root (Dockerfile COPYs nginx.conf and busybox).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ALPINE_VERSION="$(sed -n 's/^ARG ALPINE_VERSION=//p' Dockerfile)"
NGINX_VERSION="$(sed -n 's/^ARG NGINX_VERSION=//p' Dockerfile)"
[ -n "$ALPINE_VERSION" ] && [ -n "$NGINX_VERSION" ] \
  || { echo "could not read the ALPINE_VERSION / NGINX_VERSION pins from Dockerfile" >&2; exit 1; }

TAG="${IMAGE_TAG:-${NGINX_VERSION}-alpine${ALPINE_VERSION}-$(date -u +%Y%m%d)}"
IMAGE="leverj/nginx-alpine:$TAG"

command -v docker >/dev/null 2>&1 || { echo "docker not installed" >&2; exit 127; }
docker info >/dev/null 2>&1 || { echo "docker daemon not reachable; start Docker Desktop (or your docker daemon) and re-run" >&2; exit 127; }
docker buildx version >/dev/null 2>&1 || { echo "docker buildx not available; install Docker Desktop or 'brew install docker-buildx'" >&2; exit 127; }

# Keep the caller's authentication and daemon selection throughout buildx/push.
: "${DOCKER_CONFIG:?caller must supply an authenticated Docker configuration}"
[ -d "$DOCKER_CONFIG" ] || { echo "Docker configuration directory does not exist" >&2; exit 1; }
BUILDER_RESERVATION="$(mktemp -d -t nginx-builder.XXXXXX)"
BUILDER="nginx-alpine-publish-$(basename "$BUILDER_RESERVATION" | tr -dc 'A-Za-z0-9')"
cleanup() {
  docker buildx rm "$BUILDER" >/dev/null 2>&1 || true
  rm -rf "$BUILDER_RESERVATION"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
docker buildx create --name "$BUILDER" --driver docker-container --use >/dev/null

# Refuse to replace an existing version tag.
if docker buildx imagetools inspect "$IMAGE" >/dev/null 2>&1; then
  echo "$IMAGE already exists and tags are immutable; set IMAGE_TAG to publish under a new tag" >&2
  exit 1
fi

echo "Building and pushing $IMAGE (linux/amd64, nginx $NGINX_VERSION on Alpine $ALPINE_VERSION) ..."
# provenance=mode=min keeps build-arg/env detail out of the published
# attestation; still satisfies Scout's supply-chain check alongside the SBOM.
docker buildx build \
  --builder "$BUILDER" \
  --platform linux/amd64 \
  --provenance=mode=min \
  --sbom=true \
  --push \
  --tag "$IMAGE" \
  .

echo "Pushed $IMAGE. Running containers are unchanged."
