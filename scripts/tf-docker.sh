#!/usr/bin/env bash
set -euo pipefail

tf_dir="vpc"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

usage() {
  echo "Usage: $0 [-d|--dir <folder>] <up|down|init|validate|plan|apply|destroy|fmt> [extra terraform args]"
  echo "Examples:"
  echo "  $0 plan"
  echo "  $0 -d s3 plan"
  echo "  $0 --dir ec2 apply -auto-approve"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir)
      if [[ $# -lt 2 ]]; then
        usage
        exit 1
      fi
      tf_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

cmd="$1"
shift || true

workdir="/workspace/${tf_dir}"

case "$cmd" in
  up)
    docker compose -f "$repo_root/docker-compose.yml" --project-directory "$repo_root" up -d localstack
    ;;
  down)
    docker compose -f "$repo_root/docker-compose.yml" --project-directory "$repo_root" down
    ;;
  init|validate|plan|apply|destroy|fmt)
    docker compose -f "$repo_root/docker-compose.yml" --project-directory "$repo_root" up -d localstack
    docker compose -f "$repo_root/docker-compose.yml" --project-directory "$repo_root" run --rm \
      --workdir "$workdir" \
      -e TF_VAR_localstack_endpoints=http://localstack:4566 \
      terraform "$cmd" "$@"
    ;;
  *)
    echo "Unknown command: $cmd"
    echo "Allowed: up, down, init, validate, plan, apply, destroy, fmt"
    exit 1
    ;;
esac
