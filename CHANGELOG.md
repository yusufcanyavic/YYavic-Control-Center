# Changelog

## 1.0.0 - 2026-10-23 - first public release

- Menu bar app: 9 built-in effects (speed, brightness, color, direction,
  react to key presses), solid color, per-key colors with a key editor and
  quick patterns, user profiles, effect palette editor.
- Settings are stored and re-applied after wake; start at login.
- Optional permanent save to the keyboard's flash (off by default).
- 20 languages, automatic or chosen in the app.
- Command line tool `yycc-kb` and read-only `ite8291-probe`.
- Direct IOHID access to the ITE 8291 (`048d:600b`): no kext, no driver, no
  special permissions.
