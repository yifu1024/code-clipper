# CodeClipper

CodeClipper is a native macOS utility that watches incoming Messages for verification codes, copies matched codes to the clipboard, then restores the previous clipboard value after a configurable delay.

## Install

Download or build `dist/package/CodeClipper.dmg`, then:

1. Double-click `CodeClipper.dmg`.
2. Drag `CodeClipper.app` to `Applications`.
3. Open `CodeClipper` from Applications, Spotlight, or Launchpad.

To create the DMG locally:

```sh
./script/package_app.sh
```

The app icon is generated locally by `script/generate_icon.swift` and packed into the app bundle during each build.

The build script marks the app as a menu bar agent and applies local ad-hoc signing. Developer builds can still be run with:

```sh
./script/build_and_run.sh
```

## Permissions

Messages stores local message data at `~/Library/Messages/chat.db`, which macOS protects. If the app reports that it cannot open the database, grant Full Disk Access:

System Settings > Privacy & Security > Full Disk Access > add `/Applications/CodeClipper.app`

## Matching Rules

Rules are regular expressions. The app copies the configured capture group:

- `(?<!\d)(\d{6})(?!\d)` captures a standalone six digit code with group `1`.
- `(?<!\d)(\d{4,8})(?!\d)` captures a standalone four to eight digit code with group `1`.

Rules are evaluated in order, and disabled rules are skipped.
