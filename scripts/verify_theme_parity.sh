#!/usr/bin/env bash
#
# verify_theme_parity.sh
# -----------------------------------------------------------------------------
# Contract enforcement for the Levela colour palette. Reads
# assets/theme/theme-contract.json and checks that each platform's design system
# declares exactly the contracted primitives with the contracted hexes, maps the
# same semantic roles onto them in light and dark, and that
# assets/theme/THEME_COLORS.md renders the same primitives and roles.
#
# The flow contracts (splash, onboarding) point at this contract instead of
# repeating palette hexes; this verifier owns palette truth, the flow verifiers
# own their flows.
#
# A platform is only checked once its primitives file exists, so the Android and
# iOS pull requests pass independently. Pass --strict to require BOTH platforms
# (e.g. on main or in CI).
#
# Requirements: python3.
#
#   ./scripts/verify_theme_parity.sh          # check platforms that exist
#   ./scripts/verify_theme_parity.sh --strict # require both platforms
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$ROOT/assets/theme/theme-contract.json"

command -v python3 >/dev/null 2>&1 || { echo "error: 'python3' is required but not found in PATH" >&2; exit 1; }
[ -f "$CONTRACT" ] || { echo "error: contract not found: $CONTRACT" >&2; exit 1; }

exec python3 - "$CONTRACT" "$ROOT" "$@" <<'PY'
import json, os, re, sys

contract_path, root = sys.argv[1], sys.argv[2]
strict = "--strict" in sys.argv[3:]
c = json.load(open(contract_path))

errors, checked = [], []

def read(rel):
    with open(f"{root}/{rel}", "r", encoding="utf-8") as f:
        return f.read()

def parse_failed(rel, what):
    errors.append(f"{rel}: could not parse {what} (file layout changed?)")

def parse_primitives(key):
    """name(lower) -> (verbatim name, '#RRGGBB') from a platform Color file."""
    t = c["targets"][key]
    rel = t["primitivesFile"]
    src = read(rel)
    if key == "android":
        # val Blue500 = Color(0xFF0078F0)
        pattern = re.compile(r'val\s+(\w+)\s*=\s*Color\(\s*0x([0-9A-Fa-f]{2})([0-9A-Fa-f]{6})\s*\)')
        found, alphas = {}, {}
        for name, alpha, rgb in pattern.findall(src):
            found[name.lower()] = (name, "#" + rgb.upper())
            alphas[name] = alpha.upper()
        if not found:
            parse_failed(rel, "primitive declarations")
        for name, alpha in alphas.items():
            if alpha != "FF":
                errors.append(f"{rel}: primitive {name} has alpha {alpha}; contract primitives are opaque (FF)")
    else:
        # static let blue500 = Color(hex: 0x0078F0)
        pattern = re.compile(
            r'static let (\w+)\s*=\s*Color\(\s*hex:\s*0x([0-9A-Fa-f]{6})'
            r'\s*(?:,\s*opacity:\s*[0-9.]+\s*)?\)')
        found = {name.lower(): (name, "#" + rgb.upper()) for name, rgb in pattern.findall(src)}
        if not found:
            parse_failed(rel, "primitive declarations")
    return rel, src, found

def parse_semantic(key):
    """appearance -> {role: token} from a platform theme file."""
    t = c["targets"][key]
    rel = t["themeFile"]
    src = read(rel)
    schemes = {}
    if key == "android":
        # private val LightColorScheme = lightColorScheme(primary = Blue500, ...)
        for name, fn in (("light", "lightColorScheme"), ("dark", "darkColorScheme")):
            m = re.search(rf'{fn}\((.*?)\)', src, re.S)
            if not m:
                parse_failed(rel, f"{fn}(...) block")
                continue
            schemes[name] = dict(re.findall(r'(\w+)\s*=\s*(\w+)', m.group(1)))
    else:
        # public static let light = LevelaColors(primary: .blue500, ...)
        for name in ("light", "dark"):
            m = re.search(rf'static let {name}\s*=\s*LevelaColors\((.*?)\)', src, re.S)
            if not m:
                parse_failed(rel, f"LevelaColors.{name} block")
                continue
            body = m.group(1)
            # `primary: .blue500` — drop the leading dot of the Swift shorthand
            schemes[name] = {k: v for k, v in re.findall(r'(\w+)\s*:\s*\.?(\w+)', body)}
    return rel, src, schemes

def check_primitives(key):
    t = c["targets"][key]
    rel, src, theme_src, found = prim_cache[key]
    system = {k.lower(): v for k, v in t.get("systemPrimitives", {}).items()}

    for name, hexv in c["primitives"].items():
        low = name.lower()
        if low in system:
            # Platform uses its own built-in colour (e.g. iOS SwiftUI `.white`).
            token = system[low]
            if f".{token}" not in src and f".{token}" not in theme_src:
                errors.append(f"{rel}: missing system primitive .{token} ({name})")
            continue
        if low not in found:
            errors.append(f"{rel}: missing primitive {name} = {hexv}")
        elif found[low][1] != hexv.upper():
            errors.append(f"{rel}: primitive {found[low][0]} = {found[low][1]}, contract says {hexv}")

    for low, (name, hexv) in found.items():
        if low not in {p.lower() for p in c["primitives"]} and low not in system:
            errors.append(f"{rel}: undocumented primitive {name} = {hexv} (add it to the contract)")

def check_semantic(key):
    rel, src, schemes = theme_src_cache[key]
    canonical = {r.lower(): r for r in c["semantic"]["light"]}
    if {r.lower() for r in c["semantic"]["light"]} != {r.lower() for r in c["semantic"]["dark"]}:
        errors.append("theme-contract.json: semantic.light and semantic.dark declare different roles")

    for appearance in ("light", "dark"):
        expected = {r.lower(): v for r, v in c["semantic"][appearance].items()}
        if appearance not in schemes:
            continue
        actual = {r.lower(): (r, v.lower()) for r, v in schemes[appearance].items()}
        for role in sorted(set(expected) - set(actual)):
            errors.append(f"{rel}: {appearance} scheme missing role '{canonical.get(role, role)}'")
        for role in sorted(set(actual) - set(expected)):
            errors.append(f"{rel}: {appearance} scheme has undocumented role '{actual[role][0]}'")
        for role in sorted(set(expected) & set(actual)):
            if expected[role].lower() != actual[role][1]:
                errors.append(
                    f"{rel}: {appearance}.{actual[role][0]} = {actual[role][1]}, "
                    f"contract says {expected[role]}")

def check_doc():
    rel = c["humanDoc"]
    if not os.path.isfile(f"{root}/{rel}"):
        errors.append(f"{rel}: human doc not found")
        return
    doc = read(rel)

    # primitive table: | **`Blue500`** | `#0078F0` | ... |
    doc_prims = {n.lower(): (n, h.upper()) for n, h in re.findall(
        r'\|\s*\*\*`(\w+)`\*\*\s*\|\s*`(#[0-9A-Fa-f]{6})`', doc)}
    if not doc_prims:
        parse_failed(rel, "primitive table")
    for name, hexv in c["primitives"].items():
        low = name.lower()
        if low not in doc_prims:
            errors.append(f"{rel}: primitive table missing {name}")
        elif doc_prims[low][1] != hexv.upper():
            errors.append(f"{rel}: primitive {name} = {doc_prims[low][1]}, contract says {hexv}")
    documented = {p.lower() for p in c["primitives"]}
    for low, (name, hexv) in doc_prims.items():
        if low not in documented:
            errors.append(f"{rel}: primitive table lists undocumented {name} = {hexv}")

    # semantic table: | `primary` | `Blue500` | `Blue300` |
    doc_sem = {}
    for role, light, dark in re.findall(
            r'\|\s*`(\w+)`\s*\|\s*`(\w+)`\s*\|\s*`(\w+)`', doc):
        doc_sem[role.lower()] = (light, dark)
    if not doc_sem:
        parse_failed(rel, "semantic token table")
    expected_roles = {r.lower() for r in c["semantic"]["light"]}
    canonical = {r.lower(): r for r in c["semantic"]["light"]}
    for role in sorted(expected_roles - set(doc_sem)):
        errors.append(f"{rel}: semantic table missing role '{canonical.get(role, role)}'")
    for role in sorted(set(doc_sem) - expected_roles):
        errors.append(f"{rel}: semantic table has undocumented role '{role}'")
    for role in sorted(expected_roles & set(doc_sem)):
        got_light, got_dark = doc_sem[role]
        want_light = {r.lower(): v for r, v in c["semantic"]["light"].items()}[role]
        want_dark = {r.lower(): v for r, v in c["semantic"]["dark"].items()}[role]
        if got_light.lower() != want_light.lower():
            errors.append(f"{rel}: {canonical[role]} light = {got_light}, contract says {want_light}")
        if got_dark.lower() != want_dark.lower():
            errors.append(f"{rel}: {canonical[role]} dark = {got_dark}, contract says {want_dark}")

present = {k: os.path.isfile(f"{root}/{c['targets'][k]['primitivesFile']}") for k in c["targets"]}

if strict and not all(present.values()):
    for k, ok in present.items():
        if not ok:
            errors.append(f"strict: {c['targets'][k]['primitivesFile']} not found")
elif not any(present.values()):
    print("warn: no design-system Color files present yet; nothing to verify.")

prim_cache, theme_src_cache = {}, {}
for key, ok in present.items():
    if not ok:
        continue
    prim_rel, prim_src, prims = parse_primitives(key)
    theme_rel, theme_src, schemes = parse_semantic(key)
    prim_cache[key] = (prim_rel, prim_src, theme_src, prims)
    theme_src_cache[key] = (theme_rel, theme_src, schemes)
    check_primitives(key)
    check_semantic(key)
    checked.extend([prim_rel, theme_rel])

check_doc()
checked.append(c["humanDoc"])

pending = [k for k, ok in present.items() if not ok]
if pending and not strict:
    print(f"note: platform(s) pending (add with their PR): {', '.join(sorted(pending))}")

if errors:
    print("\nTHEME PARITY FAILED:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print(f"OK: theme contract satisfied ({len(checked)} checks).")
PY
