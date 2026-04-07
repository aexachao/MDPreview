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

Download the latest release from the [GitHub Releases](https://github.com/yourusername/MDPreview/releases) page.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/MDPreview.git
cd MDPreview

# Generate Xcode project
xcodegen generate

# Open in Xcode and run
open MDPreview.xcodeproj
```

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) for details.
