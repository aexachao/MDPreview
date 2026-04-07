# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MDPreview is a native macOS Markdown file preview application. It provides a clean way to view Markdown files with a collapsible sidebar showing the document outline (headings).

## Build Commands

```bash
xcodegen generate   # Generate Xcode project from project.yml
open MDPreview.xcodeproj   # Open in Xcode for building/running
```

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
