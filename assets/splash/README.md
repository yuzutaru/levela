# Splash — single source of truth

The Levela splash (launch welcome) flow is defined **once** here and mirrored by
the Android and iOS apps, so the two platforms cannot drift apart:

```
assets/splash/splash-contract.json      # THE CONTRACT: flow, copy, colours, logo, targets
scripts/generate_splash_assets.sh       # derives the logo mark on both platforms
scripts/verify_splash_parity.sh         # checks both platforms against the contract
```

The colour tokens are the primitives from [`../../THEME_COLORS.md`](../../THEME_COLORS.md)
(`Purple800/900/950`, `Purple700`, `Lavender200`, `Gray200`, `White`); the splash
is the first feature to consume them.

## The flow

Three stages, auto-advancing (timings in the contract):

| Stage | Shown |
| --- | --- |
| `brand` | logo mark only |
| `welcome` | logo mark + **Start your / Fitness Journey** |
| `actions` | logo + heading + **Login** / **Register** buttons + **Continue as a guest** |

Buttons are visual only in this iteration; the feature exposes a single
`onFinished` callback that the app wires up later. The splash shows on every
launch (there is no persistence yet).

## Change the splash

1. Edit a value in `splash-contract.json` (copy, colour token, timing, logo
   geometry, target sizes).
2. Run the generator:

   ```sh
   ./scripts/generate_splash_assets.sh
   ```

   It rewrites the logo PNGs on both platforms and verifies the result. To check
   without writing:

   ```sh
   ./scripts/verify_splash_parity.sh
   ```

## What is generated

The logo mark (a thin ring around the runner glyph) is pulled from the shared
app-icon master, `assets/app-icon/source.png`, so it stays consistent with the
launcher icon.

| Platform | Output |
| --- | --- |
| Android | `android/splash/src/main/res/drawable-*/ic_splash_logo.png` (64dp × density) |
| iOS | `ios/Packages/Splash/Sources/Splash/Resources/ic_splash_logo.png` (192px) |

## What is verified

`verify_splash_parity.sh` fails (non-zero) if either platform drifts from the
contract:

- the generated logo is missing or the wrong size, or lost its alpha channel;
- a stage name, auto-advance timing or copy string differs;
- a colour token is renamed or missing;
- the design-system `Color` file stops defining a contracted palette hex.

A platform is only checked once its `SplashTokens` file exists, so the Android
and iOS pull requests pass independently. Use `--strict` (e.g. on `main`) to
require **both** platforms.

## Requirements

`ffmpeg` and `python3`, both already used by this project. No ImageMagick or PIL.
