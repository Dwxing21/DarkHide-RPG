# DARKHIDE — Godot Project (Linux Prototype)

This is an early playable slice of DARKHIDE: character creation, the town/guild
loop, and the 10-wave tutorial dungeon with turn-based combat and the
Battle Focus skill. It's built entirely in GDScript with UI generated in code
(no hand-built scene files to fight with), so it's easy to extend.

## Requirements

- [Godot Engine 4.x](https://godotengine.org/download/linux/) (tested against
  the 4.3 feature set — should also open fine in other 4.x releases)

## Running it

1. Open Godot Engine.
2. Click **Import**, then select the `project.godot` file in this folder.
3. Once the project opens, press **F5** (or the Play button) to run it.

If Godot shows a one-time warning about the scene format on first open, just
save the project (Ctrl+S) — Godot will normalize it and the warning won't
reappear.

## Exporting a single Linux executable

1. In the editor, go to **Project → Export**.
2. The **Linux** and **Windows** export presets are already set up (in
   `export_presets.cfg`) with the app icon applied — you'll just need to add
   your export templates the first time (Editor → Manage Export Templates).
3. Export as a single binary — no extra folder of dependencies needed for the
   player to run it.

## Exporting for Android

This needs some one-time toolchain setup in Godot's editor settings before
the "Android" preset (already configured in `export_presets.cfg`) will work:

1. Install a JDK (17 is a safe bet for current Godot 4.x) and the Android
   SDK — easiest path is installing **Android Studio** and letting it pull
   the SDK/platform-tools/build-tools for you, even if you never open a
   project in it.
2. In Godot, go to **Editor → Editor Settings → Export → Android** and set:
   - **Android SDK Path** — point it at your SDK install
     (e.g. `~/Android/Sdk` on Linux)
   - **Debug Keystore** — Godot can generate one for you, or point at
     `~/.android/debug.keystore` if you already have one from Android Studio
3. Back in **Project → Export**, select the **Android** preset and hit
   **Export Project** to produce an `.apk`.
4. To install it on a phone: enable Developer Options + USB debugging on the
   phone, plug it in, and run `adb install path/to/DARKHIDE.apk` — or just
   copy the APK over and open it on-device (you'll need to allow installs
   from unknown sources).

The Android preset targets **portrait** orientation for one-handed play. The
project's stretch mode is set to `expand` (not `keep`) so the UI fills a tall
phone screen properly instead of leaving black bars top and bottom.

No code changes were needed for Android — the same `Main.gd` UI (built with
standard Buttons/Labels) works with touch input automatically.

### Installing it on your phone

Once you've exported the `.apk` from Godot (Project → Export → Android
preset → Export Project), you have two easy options:

**Option A — no cable, easiest**
1. Get the `.apk` onto your phone however's convenient (email it to
   yourself, upload to Google Drive, USB file transfer, etc.).
2. Open it from your phone's Files app / Downloads / whatever app you used.
3. Android will ask to allow installs from that source the first time —
   tap **Settings**, enable **Allow from this source**, then go back and
   tap the APK again to install.
4. Open **DARKHIDE** from your app drawer like any other app.

**Option B — over USB with adb (better for iterating quickly)**
1. On your phone: **Settings → About Phone → tap "Build Number" 7 times**
   to unlock Developer Options, then **Settings → Developer Options → USB
   debugging → on**.
2. Plug the phone into your laptop, allow the USB debugging prompt that
   pops up on the phone.
3. From a terminal: `adb install path/to/DARKHIDE.apk`
   (re-running this after a rebuild will just update the installed app)

## Project structure

```
DARKHIDE/
├── project.godot          # Engine config, sets GameState as an autoload
├── export_presets.cfg      # Pre-configured Linux + Windows export presets (uses icon.png)
├── icon.png                # App icon (hand-drawn, background removed)
├── menu_bg.png              # Main menu artwork (pixel art, upscaled nearest-neighbor)
├── scenes/
│   └── Main.tscn           # Bare Control root; all UI is built in code
└── scripts/
    ├── GameState.gd         # Player stats, leveling, damage formula (autoload singleton)
    ├── Monsters.gd          # Monster stats + tutorial dungeon wave data
    └── Main.gd              # Screen state machine: Title → Char Create → Town → Combat
```

## What's implemented

- Main menu with a bordered piece of town artwork, the title, and
  **New Game** / **Quit** buttons (the hand-drawn sword icon is used as the
  app/window icon instead — see Exporting below)
- Character creation (Warrior / Archer / Sorcerer), each with distinct base
  stats and starting weapon, per the design doc
- Town loop: visit the guild to learn **Battle Focus**, pick up the bounty
- Store: buy Healing Potions (20 gold) and Magic Flasks (15 gold)
- Tutorial dungeon: 10 waves (wave 1 = two Skeletons, waves 2-10 mix
  Skeleton + Archer Skeleton), turn-based combat
- Gold and XP rewards per monster killed
- Battle Focus skill (costs 5 MP, +20% damage on your next attack)
- Healing Potions and Magic Flasks as combat items
- XP/leveling system (150 XP to level 2, scaling stats/HP/MP on level-up)
- Flat % per-level damage scaling formula from the design doc:
  `damage = base_weapon_damage * (1 + 0.05 * level) * stat_modifier`
- Chapter 1 boss fight: the **Bone Warden**, unlocked once the tutorial
  dungeon is cleared
- First vessel swap: defeating the boss opens a Soul Box, boosts Strength and
  Crit, and grants the profession-specific skill (Slaughter for Warrior,
  Multi-Pierce for Archer, Magic Vines for Sorcerer)

## What's NOT implemented yet (next steps)

- "Continue" on the main menu (waiting on a save system, which will land
  alongside the RPi5/ESP32-S3 sync work)
- Store selling gear/weapons (currently potions/flasks only)
- A visual/cutscene moment for the vessel swap (currently just narrated text)
- ASCII art
- Save/load
- Chapters 2-10
- Any networking/sync with the RPi5 or ESP32-S3

## Notes

- All UI is built dynamically in `Main.gd` rather than as separate `.tscn`
  scene files per screen — this keeps the prototype easy to iterate on without
  needing the Godot editor open to tweak layout. We can split screens into
  their own scenes later if the project grows large enough to want that.
- `GameState` is a Godot **autoload singleton** — it persists across scene
  changes and is the single source of truth for the player's current vessel
  (stats, HP/MP, inventory, skills, gold, wave progress).
