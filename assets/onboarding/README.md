# Onboarding — single source of truth

The Levela post-guest onboarding flow (weight, height) is defined **once** here
and mirrored by the Android and iOS apps, so the two platforms cannot drift
apart:

```
assets/onboarding/onboarding-contract.json   # THE CONTRACT: steps, copy, units, ranges, colours, targets
scripts/verify_onboarding_parity.sh          # checks both platforms against the contract
```

The colour tokens are the primitives from [`../../THEME_COLORS.md`](../../THEME_COLORS.md)
(`Blue100/300/500`, `LightBlue100/300`, `Navy900`, `White`, `Gray100/200/300/500`).
The mockup's dark accents are toned to the app palette: a white canvas with
`Navy900` text and `Blue500` actions (matching the splash), and the value cards
tinted light blue (`LightBlue100` for weight, `Blue100` for height).

## The flow

Three steps, shown after the user taps **Continue as a guest** on the splash:

| Step | Shown |
| --- | --- |
| `welcome` | progress segments + **Start your Fitness Journey** + subtitle + **Let's start** |
| `weight` | progress segments + **What is your weight?** + `lb` / `kg` toggle + value card (ruler picker) |
| `height` | progress segments + **What is your height?** + `inches` / `cm` toggle + value card (ruler picker) |

The welcome step has a single primary **Let's start** button. The weight and
height steps each have a circular back button and a primary **Next** button; the
last step reports completion through `onFinished`. The progress indicator has one
segment per step (three).

The ruler picker is draggable and snaps to the nearest step; the big value
updates live. Switching unit converts the canonical value (kg ⇄ lb,
cm ⇄ inches) and re-scales the ruler. The canonical value lives in
`kg` / `cm`; the UI always shows the selected unit's value.

## Change the onboarding

1. Edit a value in `onboarding-contract.json` (copy, unit label, default, value
   range, colour token, step order).
2. Check both platforms still match:

   ```sh
   ./scripts/verify_onboarding_parity.sh          # platforms present in this checkout
   ./scripts/verify_onboarding_parity.sh --strict # require both platforms
   ```

## What is verified

`verify_onboarding_parity.sh` fails (non-zero) if either platform drifts from the
contract:

- a step name, copy string, unit label or default unit differs;
- a value range min/max/step/default number is missing;
- a colour token is renamed or missing;
- the design-system `Color` file stops defining a contracted palette hex.

A platform is only checked once its `OnboardingTokens` file exists, so the
Android and iOS pull requests pass independently. Use `--strict` (e.g. on
`main`) to require **both** platforms.
