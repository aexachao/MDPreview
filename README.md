# MDPreview

A native macOS Markdown file preview application with collapsible sidebar outline.

## Features

- **Markdown Preview**: Open and preview `.md` and `.markdown` files with live rendering
- **Document Outline**: Collapsible sidebar showing document headings (H1-H6)
- **Dark/Light Mode**: Automatic switching based on system appearance
- **Drag & Drop**: Drag markdown files directly onto the app
- **Menu Bar App**: Optional status bar icon for quick access
- **Launch at Login**: Option to start automatically on system boot

## Screenshots

*Coming soon*

## Installation

### Pre-built DMG

Download the latest release from the [GitHub Releases](https://github.com/aexachao/MDPreview/releases) page.

> **Note**: If you see a "MDPreview.app is damaged and can't be opened" error when opening the downloaded DMG, this is a macOS Gatekeeper security warning. To resolve:
>
> 1. **Method 1**: Right-click (or Control-click) on the MDPreview.app and select "Open", then click "Open" in the dialog
> 2. **Method 2**: Go to **System Settings** > **Privacy & Security** > scroll down to find "Open Anyway" option
>
> This warning appears because the app is signed with an ad-hoc signature (no paid Apple Developer certificate). The app is safe to use.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/aexachao/MDPreview.git
cd MDPreview

# Generate Xcode project
xcodegen generate

# Open in Xcode and run
open MDPreview.xcodeproj
```

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

## Version

Current version: `1.0.1`

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Architecture

MDPreview uses a **hybrid AppKit/SwiftUI** architecture:

- **AppKit**: App lifecycle, window management, menu bar, status bar
- **SwiftUI**: User interface components
- **WKWebView**: Markdown rendering via `marked.js`

### Project Structure

```
Sources/
├── main.swift              # App entry point
├── AppDelegate.swift        # App lifecycle, menus
├── Controllers/
│   ├── MainWindowController.swift
│   └── StatusBarController.swift
├── Models/
│   ├── DocumentManager.swift
│   └── SettingsManager.swift
├── Views/
│   ├── ContentView.swift
│   ├── EmptyStateView.swift
│   ├── MarkdownWebView.swift
│   ├── SettingsView.swift
│   └── TitleBarView.swift
└── Renderer/
    └── MarkdownRenderer.swift
Resources/
├── marked.min.js           # Markdown parser
└── heading-renderer.js      # Custom heading anchors
```

## Development

### Version Management

This project uses Semantic Versioning (SemVer). See `VERSION` file for current version.

### CI/CD

GitHub Actions automatically:
- Builds DMG on every push to `main`
- Uploads DMG to Release on Git Tag

## License

**GNU Affero General Public License v3.0 only**

- **Project Name**: Nas SubMaster
- **Copyright**: Copyright (C) 2025 Chris Li

See [LICENSE](LICENSE) for full license text.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
