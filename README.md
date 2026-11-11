# YYavic Control Center

**Developer:** Yusufcan Yaviç (Yusufcan Yavic) - YYavic

YYavic Control Center is a small macOS menu bar app (and command line tool) for
laptops that run macOS on non-Apple hardware (Hackintosh). **Today it does one
thing: it controls the RGB keyboard backlight** of laptops with the
**ITE 8291** controller (USB HID `048d:600b`), such as the Tongfang-chassis
**R9T Slayer**. No kext, no driver, no special permissions: it talks to the
keyboard controller directly through IOHID.

**Planned, not implemented yet:** fan speed, battery and performance
controls, and support for other chassis (for example Clevo-based laptops).
They need hardware access that this release does not have; they are listed
here only as the direction of the project. Reports from owners of other
laptops are welcome in the issues.

## Features (keyboard RGB)

- 9 built-in effects: Breathing, Wave, Random, Rainbow, Ripple, Marquee,
  Raindrop, Aurora, Fireworks, with speed, brightness, color and direction
- "React when a key is pressed" for the effects that support it
- Solid color for the whole keyboard
- **Per-key colors** (6 × 21 grid) with a key editor: brush, paint all,
  clear and quick patterns (Rainbow, Fire, Ocean, Night, White)
- Profiles: save and load your own lighting setups
- Edit the 7 colors of the effect palette
- Settings are re-applied after wake
- Start at login
- Optional "Save permanently to the keyboard" (writes the keyboard's flash so
  the setting survives a restart; off by default)
- 20 languages (follows the system language or can be chosen)
- Command line tool `yycc-kb` for scripts

## Tested on

- Tongfang-chassis R9T Slayer laptop (AMD Ryzen 9 8945HX), ITE 8291 firmware
  34.3.0.0 (USB `048d:600b`, rev 0.03), macOS 15.8.1 and macOS 26.7.2 (menu bar
  app, effects, brightness, saved settings and `yycc-kb` all work on both).

Other laptops with the same controller (`048d:600b`) should work but are
untested. The keyboard's Fn light keys keep working; they are handled by the
laptop's embedded controller, not by this app.

## Installation

1. Download `YYavic-Control-Center-1.0.0.zip` from the
   [Releases](../../releases) page and unzip it.
2. Move **YYavic Control Center.app** to `Applications` and open it. It appears in
   the menu bar (keyboard icon), not in the Dock.
3. The app is signed ad hoc and not notarized, so macOS blocks it the first
   time. Open **System Settings → Privacy & Security**, scroll down and click
   **Open Anyway** next to the message about *YYavic Control Center*.
   Alternatively, in Terminal:

   ```sh
   xattr -dr com.apple.quarantine "/Applications/YYavic Control Center.app"
   ```

4. Optional: enable **Start at login** in the app.

Requirements: macOS 13 or later, Intel/AMD (x86_64) Mac or Hackintosh.

## Command line tool

`yycc-kb` (in `YYavic-Control-Center-tools-1.0.0.zip`):

```sh
./yycc-kb info                                   # firmware and current effect
./yycc-kb off | on
./yycc-kb brightness 30                          # 0-50
./yycc-kb effect wave --speed 5 --brightness 40 --direction left
./yycc-kb effect breathing --color blue
./yycc-kb color 255 80 0 --brightness 40         # all keys one color
./yycc-kb palette 1 255 0 0                      # palette color 1 = red
```

Nothing is written to the keyboard's flash unless you add `--save`.
`ite8291-probe` only reads the firmware version and current state (writes
nothing), useful to check whether your laptop has a compatible controller.

## Building from source

Requires Xcode or the Command Line Tools (Swift 5).

```sh
zsh build.sh
# build/YYavic Control Center.app, build/yycc-kb, build/ite8291-probe
```

Use `DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer zsh build.sh` to pick
a specific Xcode. `localize/gen_strings.py` generates the 20 language files
during the build.

## License

GPL-3.0-or-later, see `LICENSE`. See `CREDITS.md` for references.
