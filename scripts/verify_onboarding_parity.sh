#!/usr/bin/env bash
#
# verify_onboarding_parity.sh
# -----------------------------------------------------------------------------
# Contract enforcement for the Levela post-guest onboarding flow. Reads
# assets/onboarding/onboarding-contract.json and checks that each platform's
# OnboardingTokens file carries the same steps, copy, units, defaults, value
# ranges and colour tokens, and that its design-system Color file defines the
# contracted palette.
#
# A platform is only checked once its OnboardingTokens file exists, so the
# Android and iOS pull requests pass independently. Pass --strict to require
# BOTH platforms (e.g. on main or in CI).
#
# Requirements: python3.
#
#   ./scripts/verify_onboarding_parity.sh          # check platforms that exist
#   ./scripts/verify_onboarding_parity.sh --strict # require both platforms
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$ROOT/assets/onboarding/onboarding-contract.json"

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

    # steps (case-insensitive)
    for step in c["flow"]["steps"]:
        if step.lower() not in low:
            errors.append(f"{tokens_rel}: missing step '{step}'")

    # copy
    for field, value in c["text"].items():
        if value not in tokens:
            errors.append(f"{tokens_rel}: missing text '{field}' = \"{value}\"")

    # unit labels + defaults
    for group, units in c["units"].items():
        for unit in units:
            if unit not in tokens:
                errors.append(f"{tokens_rel}: missing {group} unit '{unit}'")
    for field, unit in c["defaults"].items():
        if unit not in tokens:
            errors.append(f"{tokens_rel}: missing default '{field}' = \"{unit}\"")

    # value ranges/defaults
    for group, per_unit in c["values"].items():
        for unit, spec in per_unit.items():
            for field, num in spec.items():
                if str(num) not in tokens:
                    errors.append(f"{tokens_rel}: missing {group}.{unit}.{field} = {num}")

    # colour token names (Android `Navy900` / Swift `navy900` both match lowercase)
    for _, name in c["colors"].items():
        if isinstance(name, str) and name.lower() not in low:
            errors.append(f"{tokens_rel}: missing colour token '{name}'")

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
    print("warn: no OnboardingTokens files present yet; nothing to verify.")

for key, ok in present.items():
    if ok:
        check_platform(key)

pending = [k for k, ok in present.items() if not ok]
if pending and not strict:
    print(f"note: platform(s) pending (add with their PR): {', '.join(sorted(pending))}")

if errors:
    print("\nONBOARDING PARITY FAILED:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print(f"OK: onboarding contract satisfied ({len(checked)} checks).")
PY
