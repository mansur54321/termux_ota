# Termux OTA Finder

OTA firmware finder for **OnePlus**, **OPPO**, and **Realme** devices, designed specifically for **Termux** on Android.

Powered by [realme-ota](https://github.com/R0rt1z2/realme-ota) by R0rt1z2.

## Features

- One-tap setup via Termux Widget home screen shortcut
- Search OTA updates by device model, region, and version
- Supports 20 regions (China, India, Europe, Russia, etc.)
- Download link extraction with direct firmware URLs
- CSV logging with timestamps
- Interactive menu with region/version change without restart

## Quick Install

```bash
bash <(curl -sL https://raw.githubusercontent.com/mansur54321/termux_ota/main/start.sh)
```

After installation, add the **Termux Widget** to your home screen and tap **OnePlus_OTA** to launch.

## Requirements

- [Termux](https://termux.dev/) from F-Droid
- [Termux:Widget](https://wiki.termux.com/wiki/Termux:Widget) plugin
- Python, git (auto-installed by setup script)

## Usage

1. Launch via Termux Widget shortcut or run `bash /sdcard/OTA/ota.sh`
2. Enter model manually or select from device list
3. Enter manifest code + OTA version (e.g. `44F` = Europe, Second update)
4. Get OTA info: firmware version, Android version, security patch, download URL

### OTA Version Codes

| Code | Version |
|------|---------|
| A | Launch version |
| C | First update |
| F | Second update |
| H | Third update |

### Region Examples

| Code | Region |
|------|--------|
| 97 | China |
| 1B | India |
| 44 | Europe |
| 37 | Russia |
| 51 | Turkey |

## Files

- `start.sh` — Automated Termux setup script (install & configure everything)
- `ota.sh` — Main OTA finder script (downloaded to `/sdcard/OTA/`)
- `b.sh` — Shortcut launcher for Termux Widget

## How It Works

1. `start.sh` installs dependencies, downloads scripts to `/sdcard/OTA/`, creates Termux Widget shortcut at `~/.shortcuts/OnePlus_OTA`
2. Tap the widget → runs `b.sh` → launches `ota.sh` with the realme-ota Python module
3. OTA results are saved to `Ota_links.csv` with timestamps

## Credits

- [R0rt1z2/realme-ota](https://github.com/R0rt1z2/realme-ota) — Python library for OTA API
- Stano36 & SeRViP — Original OTA finder concept
