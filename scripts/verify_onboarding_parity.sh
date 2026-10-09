#!/usr/bin/env bash
#
# verify_onboarding_parity.sh
# -----------------------------------------------------------------------------
# Contract enforcement for the Levela post-guest onboarding flow. Reads
# assets/onboarding/onboarding-contract.json and checks that each platform's
# OnboardingTokens file carries the same steps, copy, units, defaults, value
# ranges and colour tokens, that its design-system Color file defines the
# contracted palette, and that the welcome illustration ships on both
# platforms at the contracted sizes.
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
import json, os, struct, sys

contract_path, root = sys.argv[1], sys.argv[2]
strict = "--strict" in sys.argv[3:]
c = json.load(open(contract_path))

errors, checked = [], []

def read(rel):
    with open(f"{root}/{rel}", "r", encoding="utf-8") as f:
        return f.read()

def png_size(rel):
    """Return (width, height) from a PNG header, or None if not a PNG/missing."""
    path = f"{root}/{rel}"
    if not os.path.isfile(path):
        return None
    with open(path, "rb") as f:
        head = f.read(26)
    if head[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", head[16:24])

def check_illustration(key):
    """The welcome hero illustration: one source, per-platform renditions."""
    ill = c.get("illustration")
    if not ill:
        return
    size = ill.get("masterSize")
    dims = png_size(ill["source"])
    if dims is None:
        errors.append(f"{ill['source']}: missing/invalid illustration source")
    elif size and dims != (size, size):
        errors.append(f"{ill['source']}: expected {size}x{size}, got {dims[0]}x{dims[1]}")

    if key == "android":
        a = ill["android"]
        for density, px in a["densities"].items():
            rel = f"android/onboarding/src/main/res/drawable-{density}/{a['drawable']}.png"
            dims = png_size(rel)
            if dims is None:
                errors.append(f"{rel}: missing/invalid illustration ({px}px)")
            elif dims != (px, px):
                errors.append(f"{rel}: expected {px}x{px}, got {dims[0]}x{dims[1]}")
    else:
        i = ill["ios"]
        base = (f"ios/Packages/Onboarding/Sources/Onboarding/Resources/"
                f"Assets.xcassets/{i['imageset']}.imageset")
        if not os.path.isfile(f"{root}/{base}/Contents.json"):
            errors.append(f"{base}/Contents.json: missing iOS imageset Contents.json")
        suffix = {"1x": "", "2x": "@2x", "3x": "@3x"}
        for scale, px in i["scales"].items():
            rel = f"{base}/welcome-illustration{suffix[scale]}.png"
            dims = png_size(rel)
            if dims is None:
                errors.append(f"{rel}: missing/invalid illustration ({px}px)")
            elif dims != (px, px):
                errors.append(f"{rel}: expected {px}x{px}, got {dims[0]}x{dims[1]}")

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

    # welcome illustration: source size + per-platform renditions
    ill = c.get("illustration")
    if ill:
        token = ill.get("cornerRadiusToken")
        if token and token.lower() not in low:
            errors.append(f"{tokens_rel}: missing illustration token '{token}'")
        if str(ill.get("cornerRadiusDp")) not in tokens:
            errors.append(f"{tokens_rel}: missing illustration cornerRadiusDp = {ill.get('cornerRadiusDp')}")
        check_illustration(key)

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
