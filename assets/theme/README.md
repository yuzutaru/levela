# Theme — single source of truth

The Levela colour palette is defined **once** here and mirrored by the Android and
iOS design systems, so the two platforms cannot drift apart:

```
assets/theme/theme-contract.json    # THE CONTRACT: primitives + semantic roles per appearance
scripts/verify_theme_parity.sh      # checks both platforms and the human doc against it
THEME_COLORS.md                     # the human-readable rendering of the contract
```

The palette is sampled from [`../app-icon/source.png`](../app-icon/source.png) (see
[`../app-icon/README.md`](../app-icon/README.md)): a white light background with
blue/green/orange accents, and a prepared deep-navy dark theme.

## The contract

`theme-contract.json` holds two tiers:

- **`primitives`** — 35 named colours (`Blue500`, `Green500`, `Orange500`, `Gray*`,
  `Navy*`, `Ink100`, `White`, …), the naming authority the flow contracts refer to.
- **`semantic`** — the 13 roles (`background`, `surface`, `surfaceVariant`,
  `primary`, `secondary`, `tertiary`, `onPrimary`, `onSecondary`, `onTertiary`,
  `onBackground`, `onSurface`, `onSurfaceVariant`, `outline`) mapped onto primitives
  for `light` and `dark`. The role set is **flat**: both platforms declare exactly
  these roles, Android onto a Material 3 `ColorScheme`, iOS onto `LevelaColors`.

Platform paths live in `targets`, along with the `naming` convention
(`PascalCase` on Android, `camelCase` on iOS) and any `systemPrimitives` — colours a
platform takes from its own framework instead of declaring. There is one today:
`White`, which iOS uses as SwiftUI's built-in `.white`, so `Color.swift` declares
34 of the 35 primitives.

## Change the theme

1. Edit a hex or a role mapping in `theme-contract.json`.
2. Update both platforms (`Color.kt` / `Theme.kt` and `Color.swift` / `Theme.swift`),
   and the matching rows in [`../../THEME_COLORS.md`](../../THEME_COLORS.md).
3. Check every layer still matches:

   ```sh
   ./scripts/verify_theme_parity.sh          # platforms present in this checkout
   ./scripts/verify_theme_parity.sh --strict # require both platforms
   ```

## What is verified

`verify_theme_parity.sh` fails (non-zero) if either platform drifts from the
contract, or if the doc drifts from both:

- a primitive is missing, renamed, has a different hex, or is undocumented on either
  platform (a colour in `Color.kt` / `Color.swift` that the contract does not list);
- a semantic role is missing, undocumented, or maps to a different primitive in
  either appearance;
- `THEME_COLORS.md`'s primitive or semantic table disagrees with the contract.

A platform is only checked once its `Color` file exists, so the Android and iOS
pull requests pass independently. Use `--strict` (e.g. on `main`) to require
**both**.

The flow contracts (`assets/splash/`, `assets/onboarding/`) no longer repeat palette
hexes: they point at this contract through `themeReference`, and their verifiers
assert that every colour they name is a contracted primitive.
