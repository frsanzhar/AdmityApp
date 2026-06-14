#!/usr/bin/env bash
# Convenience launcher for local web development.
#
# Usage:
#   ./tool/run_web.sh            # runs without a backend (offline-light)
#   ./tool/run_web.sh env.json   # runs with Supabase creds from env.json
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "${1:-}" != "" ]]; then
  exec flutter run -d chrome --dart-define-from-file="$1"
else
  echo "No env file passed — running offline-light (no Supabase backend)."
  exec flutter run -d chrome
fi
