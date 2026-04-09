# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.25] - 2026-04-09

### Changed
- Increase default window size to 1200x800

## [1.0.24] - 2026-04-09

### Fixed
- Fix VERSION file not being included in DMG build (caused settings to show old version)
- Open new window for each file opened via Finder double-click

## [1.0.23] - 2026-04-09

### Changed
- Open new window for each file opened via File > Open

## [1.0.22] - 2026-04-09

### Changed
- Toolbar title now displays filename when a file is opened

## [1.0.20] - 2026-04-08

### Changed
- App now always runs without Dock icon (stealth mode by default)

## [1.0.19] - 2026-04-08

### Added
- Stealth mode (LSUIElement) to hide Dock icon completely

### Fixed
- Fix changelog extraction for release notes

## [1.0.17] - 2026-04-08

### Fixed
- Fix scroll sync feedback loop causing flickering when scrolling

## [1.0.16] - 2026-04-08

### Fixed
- Fix settings window close crash (set isReleasedWhenClosed = false)

## [1.0.15] - 2026-04-08

### Fixed
- Fix system language detection (was broken by empty AppleLanguages array)

## [1.0.14] - 2026-04-08

### Fixed
- Fix settings panel version display (was hardcoded to 1.0.6)
- Fix settings window close crash

### Improved
- Rename DMG to include version number (MDPreview_1.0.14.dmg)

## [1.0.12] - 2026-04-08

### Fixed
- Fix changelog extraction for macOS CI runner

## [1.0.11] - 2026-04-08

### Fixed
- Fix language detection to properly follow system setting (use Locale.preferredLanguages)
- Fix settings window crash on close (EXC_BAD_ACCESS due to over-release)

## [1.0.10] - 2026-04-08

### Improved
- Update menu icons and labels
- Change status bar "Show" to "显示主界面"
- Change "New Window" icon to macwindow.badge.plus
- Change "Open..." icon to doc.badge.plus
- GitHub workflow now includes changelog as release notes

## [1.1.0] - 2026-04-08

### Added
- Add "Show" action to status bar menu for bringing window to front

### Fixed
- Fix: Open .md file when launched via file double-click
- Fix: Keep window in memory when closed to preserve document state

## [1.0.8] - 2026-04-08

### Fixed
- Fix "follow system" language detection using Locale.current

## [1.0.7] - 2026-04-08

### Added
- Full UI localization support (English, Chinese, follow system)
- Language setting in preferences panel

### Fixed
- Fix remaining hardcoded English strings in UI
- Fix app restart functionality after language change

## [1.0.6] - 2026-04-08

### Fixed
- Fix duplicate heading anchor handling (静态图-1, 选图-2, etc.)
- Fix sidebar toggle affecting all windows simultaneously
- Optimize scroll sync with 16ms throttle for smoother updates

### Improved
- Add proper AppIcon sizes for macOS

## [1.0.5] - 2026-04-08

### Improved
- Direction-aware scroll sync: switch heading when it reaches viewport edge

## [1.0.4] - 2026-04-08

### Fixed
- Improve scroll observer stability and prevent initial jumping

## [1.0.3] - 2025-04-07

### Fixed
- Fix OutlineItem equality comparison using anchor instead of UUID

## [1.0.2] - 2025-04-07

### Fixed
- Outline selection now follows scroll position (scroll sync)

## [1.0.1] - 2025-04-07

### Fixed
- Fix release workflow permissions for DMG upload

## [1.0.0] - 2025-01-01

### Added
- Initial release
- Markdown preview with WKWebView + marked.js
- Collapsible sidebar with document outline (H1-H6)
- Dark/Light mode support
- Drag & drop file support
- Menu bar status item
- Launch at login option
- GitHub Actions CI for automatic DMG builds
