#!/usr/bin/env bash
#
# generate_splash_assets.sh
# -----------------------------------------------------------------------------
# Regenerates the Levela splash logo mark for BOTH platforms from a single
# source, driven entirely by assets/splash/splash-contract.json.
#
# The mark (a thin ring around the runner glyph) is derived from the shared
# app-icon master image, so the splash logo can never drift from the launcher
# icon. The copy, colours and flow timings are NOT generated here — they live in
# each platform's SplashTokens file and are enforced by
# scripts/verify_splash_parity.sh.
#
# Requirements: ffmpeg and python3 (both already used elsewhere in this project).
# No ImageMagick / PIL needed.
#
#   ./scripts/generate_splash_assets.sh          # generate + verify
#   ./scripts/generate_splash_assets.sh --verify # verify only (no writes)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$ROOT/assets/splash/splash-contract.json"
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

logo = c["logo"]
p("SRC_REL", c["source"])
p("CANVAS", logo["canvas"])
p("R_IN", logo["ringInnerRadius"])
p("R_OUT", logo["ringOuterRadius"])
p("RUNNER_BOX", logo["runnerBox"])
p("THRESHOLD", logo["lumaThreshold"])
p("AMAX", round(float(logo["opacity"]) * 255))
p("REGION", " ".join(str(v) for v in logo["runnerRegion"]))

p("ANDROID_FILE", c["targets"]["android"]["file"])
p("ANDROID_DRAWABLE_TMPL", c["targets"]["android"]["drawableDirTemplate"])
p("ANDROID_DENSITIES", " ".join(c["targets"]["android"]["densities"].keys()))
for name, size in c["targets"]["android"]["densities"].items():
    p(f"AND_{name}", size)

p("IOS_PATH", c["targets"]["ios"]["path"])
p("IOS_SIZE", c["targets"]["ios"]["size"])

# The logo mark is tinted with the colour token referenced by colors.logo.
p("LOGO_TOKEN", c["colors"]["logo"])
palette = c.get("palette", {})
p("LOGO_HEX", palette.get(c["colors"]["logo"], "#FFFFFF"))
PY
)"

SRC="$ROOT/$SRC_REL"
[ -f "$SRC" ] || { echo "error: source image not found: $SRC" >&2; exit 1; }

read -r RX RY RW RH <<< "$REGION"
HEX="${LOGO_HEX#\#}"
COLOR="0x$HEX"                       # e.g. 0xC5BFCF
R_CH=$((16#${HEX:0:2}))
G_CH=$((16#${HEX:2:2}))
B_CH=$((16#${HEX:4:2}))
# Runner alpha slope maps luma[T..255] -> [0..AMAX]: (AMAX / (255 - T)) * luma
RUNNER_SLOPE="$(python3 -c "print(round($AMAX / (255 - $THRESHOLD), 6))")"

echo "Levela splash generator"
echo "  source   : $SRC_REL"
echo "  contract : assets/splash/splash-contract.json"
echo "  mark     : $(printf '#'${HEX}) @ ${AMAX}/255 alpha, ring ${R_IN}..${R_OUT}px of ${CANVAS}px canvas"
echo "  runner   : crop ${RW}x${RH}+${RX}+${RY}, box ${RUNNER_BOX}px, luma>${THRESHOLD}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# --- build the master mark ---------------------------------------------------
# ring: a transparent canvas with a stroked circle in the logo tint.
ffmpeg -v error -y -f lavfi -i "color=c=${COLOR}:s=${CANVAS}x${CANVAS}" \
  -vf "format=rgba,geq=r='${R_CH}':g='${G_CH}':b='${B_CH}':a='if(between(hypot(X-(W-1)/2,Y-(H-1)/2),${R_IN},${R_OUT}),${AMAX},0)'" \
  -frames:v 1 "$WORK/ring.png"

# runner: pull the runner glyph out of the app-icon badge as a tinted silhouette.
ffmpeg -v error -y -i "$SRC" \
  -vf "crop=${RW}:${RH}:${RX}:${RY},format=rgba,geq=r='${R_CH}':g='${G_CH}':b='${B_CH}':a='clip((0.299*r(X,Y)+0.587*g(X,Y)+0.114*b(X,Y)-${THRESHOLD})*${RUNNER_SLOPE},0,${AMAX})',scale=${RUNNER_BOX}:${RUNNER_BOX}:force_original_aspect_ratio=decrease" \
  -frames:v 1 "$WORK/runner.png"

# compose ring + runner into the square master mark.
ffmpeg -v error -y -i "$WORK/ring.png" -i "$WORK/runner.png" \
  -filter_complex "overlay=(W-w)/2:(H-h)/2" -frames:v 1 -update 1 "$WORK/mark.png"

if [ "$VERIFY_ONLY" -eq 0 ]; then
  echo "  iOS:"
  mkdir -p "$(dirname "$ROOT/$IOS_PATH")"
  ffmpeg -v error -y -i "$WORK/mark.png" -vf "scale=${IOS_SIZE}:${IOS_SIZE}:flags=lanczos,format=rgba" \
    -frames:v 1 -update 1 "$ROOT/$IOS_PATH"
  echo "    ${IOS_SIZE}px -> $IOS_PATH"

  echo "  Android:"
  for d in $ANDROID_DENSITIES; do
    var="AND_$d"; size="${!var}"
    dir="$ROOT/$(echo "$ANDROID_DRAWABLE_TMPL" | sed "s/{density}/$d/")"
    mkdir -p "$dir"
    ffmpeg -v error -y -i "$WORK/mark.png" -vf "scale=${size}:${size}:flags=lanczos,format=rgba" \
      -frames:v 1 -update 1 "$dir/$ANDROID_FILE"
    echo "    $d: ${size}px -> ${dir#$ROOT/}/$ANDROID_FILE"
  done
fi

# --- verify ------------------------------------------------------------------
exec "$SCRIPT_DIR/verify_splash_parity.sh" "$@"
