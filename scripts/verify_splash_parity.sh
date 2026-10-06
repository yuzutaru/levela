#!/usr/bin/env bash
#
# verify_splash_parity.sh
# -----------------------------------------------------------------------------
# Contract enforcement for the Levela splash flow. Reads
# assets/splash/splash-contract.json and checks that:
#
#   * the generated logo exists at every contracted Android density + iOS size;
#   * each platform's SplashTokens file carries the same stages, timings, copy
#     and colour tokens;
#   * each platform's design-system Color file defines the contracted palette.
#
# A platform is only checked once its SplashTokens file exists, so each of the
# Android / iOS pull requests (stacked on the shared contract) passes on its own.
# Pass --strict to require BOTH platforms (e.g. on main or in CI).
#
# Requirements: python3. No ffmpeg needed.
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
import json, os, struct, sys

contract_path, root = sys.argv[1], sys.argv[2]
strict = "--strict" in sys.argv[3:]
c = json.load(open(contract_path))

errors, checked = [], []

def read(rel):
    with open(f"{root}/{rel}", "r", encoding="utf-8") as f:
        return f.read()

def png_info(path):
    try:
        with open(path, "rb") as f:
            head = f.read(26)
    except FileNotFoundError:
        return None
    if head[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    w, h = struct.unpack(">II", head[16:24])
    return w, h, head[25] in (4, 6)  # color_type 4/6 => has alpha

# --- assets ------------------------------------------------------------------
def check_android_assets():
    t = c["targets"]["android"]
    for name, size in t["densities"].items():
        rel = f"{t['drawableDirTemplate'].format(density=name)}/{t['file']}"
        info = png_info(f"{root}/{rel}")
        if info is None:
            errors.append(f"missing/invalid PNG: {rel}")
            continue
        w, h, alpha = info
        if (w, h) != (size, size):
            errors.append(f"{rel}: expected {size}x{size}, got {w}x{h}")
        if not alpha:
            errors.append(f"{rel}: expected an alpha channel")
        checked.append(rel)

def check_ios_assets():
    t = c["targets"]["ios"]
    size = t["size"]
    info = png_info(f"{root}/{t['path']}")
    if info is None:
        errors.append(f"missing/invalid PNG: {t['path']}")
        return
    w, h, alpha = info
    if (w, h) != (size, size):
        errors.append(f"{t['path']}: expected {size}x{size}, got {w}x{h}")
    if not alpha:
        errors.append(f"{t['path']}: expected an alpha channel")
    checked.append(t["path"])

# --- token + palette parity --------------------------------------------------
palette = c["palette"]

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

    # copy
    for field, value in c["text"].items():
        if value not in tokens:
            errors.append(f"{tokens_rel}: missing text '{field}' = \"{value}\"")

    # colour token names (Android `Purple700` / Swift `purple700` both match lowercase)
    for _, name in c["colors"].items():
        if isinstance(name, str) and name.lower() not in low:
            errors.append(f"{tokens_rel}: missing colour token '{name}'")

    # logo dp size
    if str(c["logo"]["sizeDp"]) not in tokens:
        errors.append(f"{tokens_rel}: missing logo size '{c['logo']['sizeDp']}'")

    # palette hex must live in the platform design-system Color file
    design = read(design_rel)
    design_low = design.lower().replace("0x", "").replace("#", "")
    for name, hexv in palette.items():
        if hexv.lstrip("#").lower() not in design_low:
            errors.append(f"{design_rel}: missing palette {name} = {hexv}")

    checked.append(tokens_rel)
    checked.append(design_rel)

active = {k: (root + "/" + c["targets"][k]["tokensFile"]) for k in c["targets"]}
present = {k: os.path.isfile(p) for k, p in active.items()}

if strict and not all(present.values()):
    for k, ok in present.items():
        if not ok:
            errors.append(f"strict: {c['targets'][k]['tokensFile']} not found")
elif not any(present.values()):
    print("warn: no SplashTokens files present yet; nothing to verify." )

if present.get("android"):
    check_android_assets()
    check_platform("android")
if present.get("ios"):
    check_ios_assets()
    check_platform("ios")

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
