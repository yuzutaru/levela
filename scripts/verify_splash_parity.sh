#!/usr/bin/env bash
#
# verify_splash_parity.sh
# -----------------------------------------------------------------------------
# Contract enforcement for the Levela splash flow. Reads
# assets/splash/splash-contract.json and checks that each platform's
# SplashTokens file carries the same stages, timings, copy and colour tokens,
# and that its design-system Color file defines the contracted palette.
#
# The splash icon is the app's own launcher icon foreground, so there is no
# generated asset to check.
#
# A platform is only checked once its SplashTokens file exists, so the Android
# and iOS pull requests pass independently. Pass --strict to require BOTH
# platforms (e.g. on main or in CI).
#
# Requirements: python3.
#
#   ./scripts/verify_splash_parity.sh          # check platforms that exist
#   ./scripts/verify_splash_parity.sh --strict # require both platforms
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$ROOT/assets/splash/splash-contract.json"

command -v python3 >/dev/null 2>&1 || { echo "error: 'python3' is required but not found in PATH" >&2; exit 1; }
[ -f "$CONTRACT" ] || { echo "error: contract not found: $CONTRACT" >&2; exit 1; }

exec python3 - "$CONTRACT" "$ROOT" "$@" <<'PY'
import json, os, sys

contract_path, root = sys.argv[1], sys.argv[2]
strict = "--strict" in sys.argv[3:]
c = json.load(open(contract_path))

errors, checked = [], []

def read(rel):
    with open(f"{root}/{rel}", "r", encoding="utf-8") as f:
        return f.read()

def check_platform(key):
    t = c["targets"][key]
    tokens_rel, design_rel = t["tokensFile"], t["designColorFile"]
    tokens = read(tokens_rel)
    low = tokens.lower()

    # stages (case-insensitive)
    for stage in c["flow"]["stages"]:
        if stage.lower() not in low:
            errors.append(f"{tokens_rel}: missing stage '{stage}'")

    # auto-advance timings
    for ms in c["flow"]["autoAdvanceMs"].values():
        if str(ms) not in tokens:
            errors.append(f"{tokens_rel}: missing timing '{ms}'")

    # show-every-launch flag
    if str(c["flow"]["showEveryLaunch"]).lower() not in low:
        errors.append(f"{tokens_rel}: missing showEveryLaunch={c['flow']['showEveryLaunch']}")

    # show-auth-actions flag
    if str(c["flow"]["showAuthActions"]).lower() not in low:
        errors.append(f"{tokens_rel}: missing showAuthActions={c['flow']['showAuthActions']}")

    # guest entry visibility flags
    for flag in ("showGuestLink", "showGuestButton"):
        if str(c["flow"][flag]).lower() not in low:
            errors.append(f"{tokens_rel}: missing {flag}={c['flow'][flag]}")

    # copy
    for field, value in c["text"].items():
        if value not in tokens:
            errors.append(f"{tokens_rel}: missing text '{field}' = \"{value}\"")

    # colour token names (Android `Purple700` / Swift `purple700` both match lowercase)
    for _, name in c["colors"].items():
        if isinstance(name, str) and name.lower() not in low:
            errors.append(f"{tokens_rel}: missing colour token '{name}'")

    # icon dp size (per platform)
    size_dp = c["icon"]["sizeDp"][key]
    if str(size_dp) not in tokens:
        errors.append(f"{tokens_rel}: missing icon size '{size_dp}'")

    # palette hexes must live in the platform design-system Color file
    design_low = read(design_rel).lower().replace("0x", "").replace("#", "")
    for name, hexv in c["palette"].items():
        if hexv.lstrip("#").lower() not in design_low:
            errors.append(f"{design_rel}: missing palette {name} = {hexv}")

    checked.extend([tokens_rel, design_rel])

present = {k: os.path.isfile(f"{root}/{c['targets'][k]['tokensFile']}") for k in c["targets"]}

if strict and not all(present.values()):
    for k, ok in present.items():
        if not ok:
            errors.append(f"strict: {c['targets'][k]['tokensFile']} not found")
elif not any(present.values()):
    print("warn: no SplashTokens files present yet; nothing to verify.")

for key, ok in present.items():
    if ok:
        check_platform(key)

pending = [k for k, ok in present.items() if not ok]
if pending and not strict:
    print(f"note: platform(s) pending (add with their PR): {', '.join(sorted(pending))}")

if errors:
    print("\nSPLASH PARITY FAILED:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print(f"OK: splash contract satisfied ({len(checked)} checks).")
PY
