# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
