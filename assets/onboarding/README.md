# Onboarding — single source of truth

The Levela post-guest onboarding flow (welcome, goal, gender, age, weight,
height, activity) is defined **once** here and mirrored by the Android and iOS
apps, so the two platforms cannot drift apart:

```
assets/onboarding/onboarding-contract.json   # THE CONTRACT: steps, copy, units, ranges, colours, targets
scripts/verify_onboarding_parity.sh          # checks both platforms against the contract
```

The colour tokens are the primitives from [`../../THEME_COLORS.md`](../../THEME_COLORS.md)
(`Blue100/300/500/700`, `LightBlue100/300`, `Orange100/500/700`,
`Pink100/300/500/700`, `Navy900`, `White`, `Gray100/200/300/500`).
The mockup's dark accents are toned to the app palette: a white canvas with
`Navy900` text and `Blue500` actions (matching the splash), and the value cards
tinted light blue (`LightBlue100` for weight, `Blue100` for height).

## The flow

Seven steps, shown after the user taps **Continue as a guest** on the splash:

| Step | Shown |
| --- | --- |
| `welcome` | progress segments + hero illustration + **Start your Fitness Journey** + subtitle + **Let's start** |
| `goal` | progress segments + **What is your goal?** + seven single-select goal cards (dot + title + subtitle) + back / Next |
| `gender` | progress segments + **What is your Gender?** + subtitle + a single-screen carousel of three gender cards (symbol + label + check) + **Prefer to skip this** + back / Continue |
| `age` | progress segments + **Age** (vertical snapping wheel picker, `years`) + back / Next |
| `weight` | progress segments + **What is your weight?** + `lb` / `kg` toggle + value card (ruler picker) |
| `height` | progress segments + **What is your height?** + `ft/in` / `cm` toggle + value card (ruler picker) |
| `activity` | progress segments + **What is your activity level?** + five single-select activity cards (dot + title + subtitle) + back / Next |

The welcome step has a single primary **Let's start** button. The goal, gender,
age, weight, height and activity steps each have a circular back button and a
primary **Continue** or **Next** button; the last step (activity) reports
completion through `onFinished`. The goal, gender and activity steps use
single-select cards (choosing one activates it and deactivates the others), and
their primary button stays disabled until a choice is made — a goal, a gender,
or an activity level (the age always has a default). The gender step also has a
secondary **Prefer to skip this** pill that advances with the gender left unset. The
progress indicator has one segment per step (seven).

The gender cards each show a large gender symbol (female / male / neutral)
drawn from strokes, on a tinted disc, alongside the option's label and a small
check indicator. Each card is
colour-coded: female uses the `Pink` scale, male uses `Blue`, and
**Prefer not to say** uses `Orange`. Unselected cards use a pastel surface
(`Pink100` / `Blue100` / `Orange100`) with the matching accent; the selected card
fills with its saturated accent and uses the accent's on-colour for text. The
cards sit in a snapping carousel with the selected card centred and its
neighbours peeking at the edges, so the whole step fits one screen without
vertical scrolling.

The welcome step shows the hero illustration
(`assets/onboarding/welcome-illustration.png`) between the subtitle and the
**Let's start** button, aspect-fit with rounded corners (the card radius). Both
platforms ship renditions of that one source, declared under `illustration` in
the contract:

| Platform | Rendition |
| --- | --- |
| Android | `android/onboarding/src/main/res/drawable-*/welcome_illustration.png` (mdpi→xxxhdpi) |
| iOS | `ios/Packages/Onboarding/Sources/Onboarding/Resources/Assets.xcassets/WelcomeIllustration.imageset/` (1x/2x/3x) |

To replace the artwork, drop a new square master in
`assets/onboarding/welcome-illustration.png` (1280×1280) and regenerate the
renditions (macOS `sips`):

```sh
sips -z 1280 1280 new-art.png --out assets/onboarding/welcome-illustration.png
for d in mdpi:312 hdpi:468 xhdpi:624 xxhdpi:936 xxxhdpi:1248; do
  n=${d%:*}; px=${d#*:}
  sips -z "$px" "$px" assets/onboarding/welcome-illustration.png \
    --out "android/onboarding/src/main/res/drawable-$n/welcome_illustration.png"
done
for s in "1x:312:" "2x:624:@2x" "3x:936:@3x"; do
  sc=${s%%:*}; rest=${s#*:}; px=${rest%%:*}; suf=${rest#*:}
  sips -z "$px" "$px" assets/onboarding/welcome-illustration.png \
    --out "ios/Packages/Onboarding/Sources/Onboarding/Resources/Assets.xcassets/WelcomeIllustration.imageset/welcome-illustration$suf.png"
done
```

`verify_onboarding_parity.sh` fails if any rendition is missing or the wrong
size.

The age step uses a vertical snapping wheel: the selected age sits in the
vertical centre in a solid `Blue500` card with white text, while the
neighbouring ages shrink and fade (`Navy900` then `Gray300`). Scrolling (or
tapping a row) commits the centred age; the range is the contract's
`ageMin…ageMax`, default `ageDefault`.

The weight and height steps use a horizontal ruler picker: it is draggable and
snaps to the nearest step; the big value updates live. Switching unit converts
the canonical value (kg ⇄ lb, cm ⇄ ft/in) and re-scales the ruler. The canonical
value lives in `kg` / `cm`; the UI always shows the selected unit's value —
imperial height is stored as total inches underneath and displayed as
feet'inches" (e.g. 67 → `5'7"`), with a label on each foot boundary.

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
- a goal card's title or subtitle, an activity-level card's title or subtitle,
  or a gender option's persisted value, label, symbol or card colours, is missing;
- a value range min/max/step/default number is missing;
- a colour token is renamed or missing;
- the welcome illustration source or a platform rendition is missing or the wrong size;
- the design-system `Color` file stops defining a contracted palette hex.

A platform is only checked once its `OnboardingTokens` file exists, so the
Android and iOS pull requests pass independently. Use `--strict` (e.g. on
`main`) to require **both** platforms.
