# App icon — single source of truth

Both the Android and iOS launcher icons are generated from **one** master image by
**one** script. There is no per-platform hand-editing, so the two can't drift apart.

```
assets/app-icon/source.png            # the master artwork (1254x1254, transparent bg)
assets/app-icon/appicon-contract.json # THE CONTRACT: source, colours, safe zone, every output
scripts/generate_icons.sh             # deterministic generator (ffmpeg + python3)
```

## Change the icon

1. Replace `assets/app-icon/source.png` with the new artwork (square, transparent
   background), **or** tweak a value in `appicon-contract.json` (background colour,
   safe zone, sizes).
2. Run the generator:

   ```sh
   ./scripts/generate_icons.sh
   ```

It rewrites every icon on both platforms **and** verifies each output against the
contract (existence, pixel size, and alpha/opacity). It exits non-zero on any
mismatch. To check without writing anything:

```sh
./scripts/generate_icons.sh --verify
```

## What gets generated

**iOS** — `ios/Levela/Assets.xcassets/AppIcon.appiconset/`

| File | Size | Alpha | Appearance |
| --- | --- | --- | --- |
| `AppIcon-1024.png` | 1024 | none (opaque) | Any / Light |
| `AppIcon-1024-dark.png` | 1024 | yes | Dark (system draws the background) |
| `AppIcon-1024-tinted.png` | 1024 | none (opaque, grayscale on black) | Tinted |

**Android** — `android/app/src/main/res/`

| Asset | mdpi | hdpi | xhdpi | xxhdpi | xxxhdpi |
| --- | --- | --- | --- | --- | --- |
| `drawable-*/ic_launcher_foreground.png` | 108 | 162 | 216 | 324 | 432 |
| `drawable-*/ic_launcher_monochrome.png` | 108 | 162 | 216 | 324 | 432 |
| `mipmap-*/ic_launcher.png` | 48 | 72 | 96 | 144 | 192 |
| `mipmap-*/ic_launcher_round.png` | 48 | 72 | 96 | 144 | 192 |

The adaptive icon (`mipmap-anydpi-v26/ic_launcher{,_round}.xml`) composes:

- **background** → `@color/ic_launcher_background` (`values/colors.xml`)
- **foreground** → the artwork, scaled to fit Android's 66dp safe zone of the 108dp canvas
- **monochrome** → a white silhouette for Android 13+ themed icons

## Requirements

`ffmpeg` and `python3`, both already used by this project. No ImageMagick or PIL.
