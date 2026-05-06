# CodeClipper

CodeClipper is a native macOS utility that watches incoming Messages for verification codes, copies matched codes to the clipboard, then restores the previous clipboard value after a configurable delay.

## Run

Use the Codex Run action, or run:

```sh
./script/build_and_run.sh
```

The script builds the SwiftPM app, stages `dist/CodeClipper.app`, and launches it as a normal macOS app bundle.

## Install Like A Normal App

Run:

```sh
./script/install_app.sh
```

This installs the app to `~/Applications/CodeClipper.app`, where it can be opened from Finder, Spotlight, and normal app launch surfaces.

The app icon is generated locally by `script/generate_icon.swift` and packed into the app bundle during each build.

The build script also marks the app as a menu bar agent and applies local ad-hoc signing. To create a distributable zip:

```sh
./script/package_app.sh
```

## Permissions

Messages stores local message data at `~/Library/Messages/chat.db`, which macOS protects. If the app reports that it cannot open the database, grant Full Disk Access:

System Settings > Privacy & Security > Full Disk Access > add `CodeClipper`

## Matching Rules

Rules are regular expressions. The app copies the configured capture group:

- `(?<!\d)(\d{6})(?!\d)` captures a standalone six digit code with group `1`.
- `(?<!\d)(\d{4,8})(?!\d)` captures a standalone four to eight digit code with group `1`.

Rules are evaluated in order, and disabled rules are skipped.
