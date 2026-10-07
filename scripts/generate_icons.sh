#!/usr/bin/env bash
#
# generate_icons.sh
# -----------------------------------------------------------------------------
# Regenerates EVERY Levela app icon (Android + iOS) from one master image,
# driven entirely by assets/app-icon/appicon-contract.json.
#
# This is the "contract" enforcement point: both platforms are derived from the
# same source + the same parameters, so their icons cannot drift apart. Run it
# after changing source.png, the background colours, or the safe zone.
#
# Requirements: ffmpeg and python3 (both already used elsewhere in this project).
# No ImageMagick / PIL needed.
#
#   ./scripts/generate_icons.sh          # generate + verify
#   ./scripts/generate_icons.sh --verify # verify only (no writes)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$ROOT/assets/app-icon/appicon-contract.json"
VERIFY_ONLY=0
[ "${1:-}" = "--verify" ] && VERIFY_ONLY=1

for bin in ffmpeg python3; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: '$bin' is required but not found in PATH" >&2; exit 1; }
done
[ -f "$CONTRACT" ] || { echo "error: contract not found: $CONTRACT" >&2; exit 1; }

# --- read the contract -------------------------------------------------------
eval "$(python3 - "$CONTRACT" <<'PY'
import json, shlex, sys
c = json.load(open(sys.argv[1]))
def p(k, v): print(f"{k}={shlex.quote(str(v))}")
p("SRC_REL", c["source"])
p("BG_LIGHT", c["background"]["light"])
p("BG_DARK", c["background"]["dark"])
p("BG_TINTED", c["background"]["tinted"])
p("CANVAS_DP", c["android"]["adaptive"]["canvasDp"])
p("SAFE_DP", c["android"]["adaptive"]["safeZoneDp"])
p("IOS_SIZE", c["ios"]["size"])
p("IOS_DIR", c["ios"]["appiconset"])
p("DENSITIES", " ".join(c["android"]["densities"].keys()))
for name, d in c["android"]["densities"].items():
    p(f"FG_{name}", d["foreground"])
    p(f"LEG_{name}", d["legacy"])
PY
)"

SRC="$ROOT/$SRC_REL"
IOS_PATH="$ROOT/$IOS_DIR"
[ -f "$SRC" ] || { echo "error: source image not found: $SRC" >&2; exit 1; }

hex2ff() { printf '0x%s' "${1#\#}"; }   # #FFFFFF -> 0xFFFFFF

# --- detect the opaque content bounding box ----------------------------------
# alphaextract turns transparency into black; bbox then reports the smallest
# box that contains all visible pixels. That lets us scale the actual artwork
# (not its surrounding margin) into Android's adaptive-icon safe zone.
BBOX="$(ffmpeg -hide_banner -i "$SRC" -vf "alphaextract,bbox=min_val=1" -frames:v 1 -f null - 2>&1 \
        | grep -o 'crop=[0-9]\+:[0-9]\+:[0-9]\+:[0-9]\+' | tail -1 || true)"
if [ -n "$BBOX" ]; then
  CROP="${BBOX#crop=}"                       # W:H:X:Y
else
  CROP="$(ffmpeg -hide_banner -i "$SRC" -vf "null" -frames:v 1 -f null - 2>&1 \
          | grep -o '[0-9]\+x[0-9]\+' | head -1 | sed 's/x/:/')":0:0
  echo "warn: alpha bounding box not detected; using full canvas ($CROP)" >&2
fi

echo "Levela icon generator"
echo "  source   : $SRC_REL"
echo "  contract : assets/app-icon/appicon-contract.json"
echo "  artwork  : $CROP   (W:H:X:Y of opaque pixels)"

# --- generation helpers ------------------------------------------------------
# full_flat <W> <H> <#bg> <out> [pre-filter]
#   Scale the WHOLE source canvas to WxH and flatten onto an opaque background.
full_flat() {
  local w="$1" h="$2" bg="$3" out="$4" pre="${5:-}"
  local chain="scale=${w}:${h}:flags=lanczos"
  [ -n "$pre" ] && chain="${chain},${pre}"
  ffmpeg -v error -y -f lavfi -i "color=c=$(hex2ff "$bg"):s=${w}x${h}" -i "$SRC" \
    -filter_complex "[1:v]${chain}[fg];[0:v][fg]overlay=format=auto:shortest=1,format=rgb24" \
    -frames:v 1 "$out"
}

# full_alpha <W> <H> <out>
#   Scale the whole source canvas to WxH keeping transparency (RGBA).
full_alpha() {
  ffmpeg -v error -y -i "$SRC" \
    -vf "scale=$1:$2:flags=lanczos,format=rgba" -frames:v 1 "$3"
}

# fit_safe <canvas> <out> [mono]
#   Crop to the artwork, fit it inside the adaptive-icon safe zone, and centre
#   it on a transparent canvas. `mono` renders a white silhouette (themed icon).
fit_safe() {
  local canvas="$1" out="$2" mono="${3:-}"
  local safe=$(( canvas * SAFE_DP / CANVAS_DP ))
  local extra=""
  [ "$mono" = "mono" ] && extra=",lutrgb=r=255:g=255:b=255"
  ffmpeg -v error -y -i "$SRC" \
    -vf "crop=${CROP},scale=${safe}:${safe}:force_original_aspect_ratio=decrease:flags=lanczos,pad=${canvas}:${canvas}:(ow-iw)/2:(oh-ih)/2:color=0x00000000,format=rgba${extra}" \
    -frames:v 1 "$out"
}

# round_legacy <size> <out>
#   Pre-masked circular icon for the legacy android:roundIcon slot.
round_legacy() {
  local size="$1" out="$2"
  ffmpeg -v error -y -i "$SRC" \
    -filter_complex "crop=${CROP},scale=${size}:${size}:force_original_aspect_ratio=decrease:flags=lanczos,pad=${size}:${size}:(ow-iw)/2:(oh-ih)/2:color=$(hex2ff "$BG_LIGHT"),format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lte(hypot(X-(W-1)/2,Y-(H-1)/2),(W-1)/2),255,0)'" \
    -frames:v 1 "$out"
}

# --- generate -----------------------------------------------------------------
if [ "$VERIFY_ONLY" -eq 0 ]; then
  mkdir -p "$IOS_PATH"

  echo "  iOS:"
  full_flat  "$IOS_SIZE" "$IOS_SIZE" "$BG_LIGHT"  "$IOS_PATH/AppIcon-1024.png"          # Light (opaque)
  full_flat  "$IOS_SIZE" "$IOS_SIZE" "$BG_DARK"   "$IOS_PATH/AppIcon-1024-dark.png"     # Dark (opaque navy)
  full_flat  "$IOS_SIZE" "$IOS_SIZE" "$BG_TINTED" "$IOS_PATH/AppIcon-1024-tinted.png" "hue=s=0"
  echo "    light / dark / tinted -> $IOS_DIR/"

  echo "  Android:"
  for d in $DENSITIES; do
    local_fg="FG_$d"; local_leg="LEG_$d"
    fg="${!local_fg}"; leg="${!local_leg}"
    drawable="$ROOT/android/app/src/main/res/drawable-$d"
    mipmap="$ROOT/android/app/src/main/res/mipmap-$d"
    mkdir -p "$drawable" "$mipmap"
    fit_safe "$fg" "$drawable/ic_launcher_foreground.png"
    fit_safe "$fg" "$drawable/ic_launcher_monochrome.png" mono
    full_flat "$leg" "$leg" "$BG_LIGHT" "$mipmap/ic_launcher.png"
    round_legacy "$leg" "$mipmap/ic_launcher_round.png"
    echo "    $d: foreground ${fg}px, monochrome ${fg}px, legacy ${leg}px"
  done
fi

# --- verify (contract enforcement) -------------------------------------------
# Reads PNG headers directly (no PIL) and checks every declared target exists,
# has the expected size, and matches the expected alpha/opacity requirement.
python3 - "$CONTRACT" "$ROOT" <<'PY'
import json, struct, sys
contract_path, root = sys.argv[1], sys.argv[2]
c = json.load(open(contract_path))

def png_info(path):
    with open(path, "rb") as f:
        head = f.read(26)
    if head[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    w, h = struct.unpack(">II", head[16:24])
    color_type = head[25]
    has_alpha = color_type in (4, 6)
    return w, h, has_alpha

errors, checked = [], 0

ios_dir = c["ios"]["appiconset"]
for t in c["targets"]["ios"]:
    path = f"{root}/{ios_dir}/{t['file']}"
    info = png_info(path)
    checked += 1
    if info is None:
        errors.append(f"missing/invalid PNG: {ios_dir}/{t['file']}")
        continue
    w, h, has_alpha = info
    if (w, h) != (t["size"], t["size"]):
        errors.append(f"{t['file']}: expected {t['size']}x{t['size']}, got {w}x{h}")
    if t["opaque"] and has_alpha:
        errors.append(f"{t['file']}: must be opaque (no alpha channel)")
    if not t["opaque"] and not has_alpha:
        errors.append(f"{t['file']}: expected an alpha channel")

densities = c["android"]["densities"]
for t in c["targets"]["android"]:
    for name, d in densities.items():
        size = d[t["sizeFrom"]]
        rel = t["pathTemplate"].format(density=name)
        info = png_info(f"{root}/{rel}")
        checked += 1
        if info is None:
            errors.append(f"missing/invalid PNG: {rel}")
            continue
        w, h, has_alpha = info
        if (w, h) != (size, size):
            errors.append(f"{rel}: expected {size}x{size}, got {w}x{h}")
        if t["opaque"] and has_alpha:
            errors.append(f"{rel}: must be opaque (no alpha channel)")

# Adaptive launcher background resources must mirror the contract backgrounds.
for rel, key in (
    ("android/app/src/main/res/values/colors.xml", "light"),
    ("android/app/src/main/res/values-night/colors.xml", "dark"),
):
    try:
        with open(f"{root}/{rel}", encoding="utf-8") as f:
            text = f.read().lower().replace("#", "")
    except OSError:
        errors.append(f"missing launcher background resource: {rel}")
        continue
    expected = c["background"][key].lstrip("#").lower()
    if expected not in text:
        errors.append(f"{rel}: ic_launcher_background must be {c['background'][key]}")

if errors:
    print("\nCONTRACT VALIDATION FAILED:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)
print(f"\nOK: {checked} icon files match the contract.")
PY
