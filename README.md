# DARKHIDE

A turn-based, story-driven dark fantasy RPG built in Godot 4. Inspired by
**Grim Quest**.

A hidden city in the mountains near ancient Athens, cut off from the world by
a curse. Caves beneath the mountains hide gates torn open by godly conflict —
and the power of **Vessel Swap**, which lets you take on the bodies and
abilities of fallen gods. Every chapter boss you defeat grants a new vessel:
a full physical transformation with its own stats and combat style, while the
same consciousness — the same you — persists underneath.

## Status

Early prototype. The tutorial slice is playable: main menu, character
creation (Warrior / Archer / Sorcerer), the town (Guild + Store), a 10-wave
tutorial dungeon, the first chapter boss, and the first vessel swap.

Chapters 2–10, the RPi5/ESP32-S3 sync system, and mobile (Android/iOS)
polish are still in progress.

## Repo structure

```
darkhide-rpg/
├── README.md
├── docs/
│   └── DARKHIDE_Design_Doc.txt      # Full game design doc (story, stats, systems)
├── godot-project/
│   └── DARKHIDE_godot_project.zip   # Full Godot 4 source project
└── builds/
    ├── windows/
    │   └── DARKHIDE.exe             # Single-file Windows build
    ├── linux/
    │   └── DARKHIDE.x86_64          # Single-file Linux build
    └── android/
        └── DARKHIDE.apk             # Android build (portrait)
```

(iOS build coming later — Godot can export to iOS, but it requires building
on macOS with Xcode, so that build will be added once that's set up.)

## Running the builds

- **Windows**: download `builds/windows/DARKHIDE.exe`, run it directly. No
  installer, no extra files needed.
- **Linux**: download `builds/linux/DARKHIDE.x86_64`, mark it executable
  (`chmod +x DARKHIDE.x86_64`), then run it.
- **Android**: download `builds/android/DARKHIDE.apk` to your phone, allow
  installs from that source when prompted, and open it.

## Building it yourself from source

1. Download `godot-project/DARKHIDE_godot_project.zip` and unzip it.
2. Open [Godot 4.x](https://godotengine.org/download) and import the
   `project.godot` file inside the unzipped folder.
3. Press **F5** to run it in the editor, or use **Project → Export** to
   build your own binary for Windows, Linux, or Android (export presets are
   already configured in the project).

## Tech stack

- **Game**: Godot 4 (GDScript), exported to Windows, Linux, and Android from
  a single project
- **Sync server** (planned): a small Python server, run locally on a
  Raspberry Pi 5 acting as its own offline WiFi access point — no internet
  exposure
- **Portable client** (planned): custom C++/Arduino firmware for an
  ESP32-S3 with a TFT screen, running a lightweight offline version of the
  game that syncs with the Pi when back in range

## Design philosophy

- Tight, minimal loops — no feature bloat. Town is intentionally just a
  Guild (bounties, skills) and a Store (consumables + level-gated weapons).
- Linear, one-way structure — no backtracking.
- Weapons persist across vessels; other stats reset with each new vessel,
  and each vessel is a strict upgrade over the last.

See `docs/DARKHIDE_Design_Doc.txt` for the full breakdown of stats, combat
formulas, and the story so far.
