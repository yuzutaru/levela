# Splash — single source of truth

The Levela splash (launch welcome) flow is defined **once** here and mirrored by
the Android and iOS apps, so the two platforms cannot drift apart:

```
assets/splash/splash-contract.json      # THE CONTRACT: flow, copy, colours, icon, targets
scripts/verify_splash_parity.sh         # checks both platforms against the contract
```

The colour tokens are the primitives from [`../../THEME_COLORS.md`](../../THEME_COLORS.md)
(`Blue500/700`, `LightBlue100/300`, `Gray100/500`, `Navy900`, `White`); the splash
is the first feature to consume them. The splash is now light-themed: a white
canvas with a soft light-blue glow and icon-blue actions.

The splash **icon is the app's own launcher icon foreground**, not a generated
asset: Android uses `@drawable/ic_launcher_foreground` (the adaptive-icon
foreground) and iOS uses the `AppIcon` artwork. Both come from the app-icon
pipeline, so there is nothing extra to generate or keep in sync. Its size is
**per platform** in the contract (`icon.sizeDp`: `android` 204, `ios` 96); the
verifier checks each platform against its own value.

## The flow

Three stages, auto-advancing (timings in the contract):

| Stage | Shown |
| --- | --- |
| `brand` | app icon only |
| `welcome` | app icon + **Start your / Fitness Journey** |
| `actions` | app icon + heading + **Continue as a guest** button (+ hidden **Login** / **Register** buttons, hidden guest link) |

Buttons are visual only in this iteration; the feature exposes a single
`onFinished` callback that the app wires up later. The splash shows on every
launch (there is no persistence yet).

The Login / Register buttons are **hidden, not removed**: their copy and colours
stay in the contract and both platforms' `SplashTokens`, gated by
`flow.showAuthActions` (currently `false`). Flip it to `true` in
`splash-contract.json` to show them again once accounts land.

The guest entry is now a primary **Continue as a guest** button, styled like the
old Register button (Blue500 / White), gated by `flow.showGuestButton`
(currently `true`). The previous underlined text link is **hidden, not removed**,
gated by `flow.showGuestLink` (currently `false`). Both use the same `guest`
copy and the existing `registerBackground` / `registerText` colours.

## Change the splash

1. Edit a value in `splash-contract.json` (copy, colour token, timing, icon size,
   stage order).
2. Check both platforms still match:

   ```sh
   ./scripts/verify_splash_parity.sh          # platforms present in this checkout
   ./scripts/verify_splash_parity.sh --strict # require both platforms
   ```

## What is verified

`verify_splash_parity.sh` fails (non-zero) if either platform drifts from the
contract:

- a stage name, auto-advance timing, copy string or icon size (per platform) differs;
- a colour token is renamed or missing;
- the design-system `Color` file stops defining a contracted palette hex.

A platform is only checked once its `SplashTokens` file exists, so the Android
and iOS pull requests pass independently. Use `--strict` (e.g. on `main`) to
require **both** platforms.
