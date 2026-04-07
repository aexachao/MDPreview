# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MDPreview is a native macOS Markdown file preview application. It provides a clean way to view Markdown files with a collapsible sidebar showing the document outline (headings).

## Build Commands

```bash
xcodegen generate   # Generate Xcode project from project.yml
open MDPreview.xcodeproj   # Open in Xcode for building/running
```

## Version Management

This project uses **Semantic Versioning (SemVer)**.

### Version File
- `VERSION` - Contains the current version in format `MAJOR.MINOR.PATCH`
  - MAJOR: Breaking changes
  - MINOR: New features (backward compatible)
  - PATCH: Bug fixes

### Version Update Rules
1. **BEFORE making any changes**: Read `VERSION` file to know current version
2. **After releasing**: Update `VERSION` and `CHANGELOG.md` with new version
3. **GitHub Releases**: Tag format must match version: `v1.0.0`

### Release Process
1. Update `CHANGELOG.md`: Add new version entry with date
2. Update `VERSION`: Bump version number
3. Commit with message: `Release v1.0.0`
4. Create Git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
5. Push: `git push && git push --tags`
6. GitHub Actions will automatically build and attach DMG to release

## Architecture

### App Lifecycle (AppKit)
- `Sources/main.swift` - Manual app startup (NSApplication.shared.run())
- `Sources/AppDelegate.swift` - App lifecycle, menu bar setup, status bar, settings window

### Controllers
- `MainWindowController` - Main window with toolbar (sidebar toggle, settings, open file)
- `StatusBarController` - macOS menu bar icon and dropdown menu

### Models
- `DocumentManager` - File loading, Markdown content state, outline parsing
- `SettingsManager` - UserDefaults-backed settings (launch at login, dock icon visibility, status bar icon)

### Views (SwiftUI)
- `ContentView` - Main view with collapsible sidebar and Markdown display area
- `MarkdownWebView` - WKWebView wrapper for HTML rendering
- `EmptyStateView` - Initial empty state with open file button
- `SettingsView` - Settings panel

### Renderer
- `MarkdownRenderer` - Converts Markdown to HTML using `marked.js` (bundled in Resources)
- `Resources/marked.min.js` - Markdown parsing library
- `Resources/heading-renderer.js` - Custom heading renderer for anchor links

## Key Design Decisions

- **Hybrid AppKit/SwiftUI**: App lifecycle uses AppKit (NSApplication, NSWindowController), UI uses SwiftUI views hosted in NSHostingView
- **WKWebView for Rendering**: Markdown is rendered to HTML and displayed in WKWebView for consistent typography
- **Outline Parsing**: DocumentManager extracts h1-h6 headings to build an outline; clicking an outline item scrolls to that heading anchor in the WebView
- **Settings via UserDefaults**: SettingsManager uses @Published properties synced with UserDefaults
- **File Drag & Drop**: ContentView accepts .md/.markdown files dropped onto the empty state

## Legal

- **License**: GNU Affero General Public License v3.0 only
- **Copyright**: Nas SubMaster, Copyright (C) 2025 Chris Li
- **All source files** must include the AGPL header notice

## Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes with clear messages
3. Push and create Pull Request
4. Ensure CI passes (build succeeds)
