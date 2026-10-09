#!/usr/bin/env bash
#
# Point git at the tracked hooks in scripts/hooks so the pre-commit guard runs.
# Run once per clone:
#
#   ./scripts/install-hooks.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod +x scripts/hooks/pre-commit
git config core.hooksPath scripts/hooks
echo "core.hooksPath -> scripts/hooks (android/ios commit guard active)"
