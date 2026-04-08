import AppKit
import SwiftUI

class MainWindowController: NSWindowController {
    private var documentManager = DocumentManager()
    private var contentView: ContentView?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 650),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "MDPreview"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.center()
        window.minSize = NSSize(width: 600, height: 400)
        window.setFrameAutosaveName("MainWindow-\(UUID().uuidString)")
        window.isReleasedWhenClosed = true  // Keep window in memory when closed

        self.init(window: window)

        setupContentView()
        setupToolbar()
    }

    private func setupContentView() {
        contentView = ContentView(documentManager: documentManager, windowId: window?.hashValue ?? 0)
        let hostingView = NSHostingView(rootView: contentView!)
        window?.contentView = hostingView
    }

    private func setupToolbar() {
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        window?.toolbar = toolbar
    }

    override func showWindow(_ sender: Any?) {
        window?.makeKeyAndOrderFront(sender)
        window?.makeFirstResponder(window?.contentView)
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "md")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        panel.beginSheetModal(for: window!) { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.loadFile(url: url)
            }
        }
    }

    private func loadFile(url: URL) {
        documentManager.loadFile(url: url)
        window?.title = url.lastPathComponent
        window?.makeKeyAndOrderFront(nil)
    }

    func openFile(at url: URL) {
        loadFile(url: url)
    }
}

extension MainWindowController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let s = Strings.shared
        switch itemIdentifier.rawValue {
        case "SidebarToggle":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = s.outline
            item.paletteLabel = s.toggleOutline
            item.toolTip = s.toggleOutline
            let config = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            item.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: s.outline)?.withSymbolConfiguration(config)
            item.target = self
            item.action = #selector(toggleSidebar(_:))
            return item

        case "AppTitle":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "MDPreview"
            let textField = NSTextField(labelWithString: "MDPreview")
            textField.font = NSFont.boldSystemFont(ofSize: 13)
            textField.textColor = .labelColor
            item.view = textField
            return item

        case "Settings":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = s.settings
            item.paletteLabel = s.settings
            item.toolTip = s.settings
            let config = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            item.image = NSImage(systemSymbolName: "gear", accessibilityDescription: s.settings)?.withSymbolConfiguration(config)
            item.target = self
            item.action = #selector(showSettingsAction(_:))
            return item

        case "OpenFile":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = s.open
            item.paletteLabel = s.open
            item.toolTip = s.open
            let config = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            item.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: s.open)?.withSymbolConfiguration(config)
            item.target = self
            item.action = #selector(openFileAction(_:))
            return item

        case "FlexibleSpace":
            return NSToolbarItem(itemIdentifier: .flexibleSpace)

        default:
            return nil
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            NSToolbarItem.Identifier("AppTitle"),
            NSToolbarItem.Identifier("SidebarToggle"),
            .flexibleSpace,
            NSToolbarItem.Identifier("Settings"),
            NSToolbarItem.Identifier("OpenFile")
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    @objc func toggleSidebar(_ sender: Any?) {
        NotificationCenter.default.post(name: .toggleSidebar, object: window?.hashValue)
    }

    @objc func showSettingsAction(_ sender: Any?) {
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }

    @objc func openFileAction(_ sender: Any?) {
        openFile()
    }
}

extension Notification.Name {
    static let toggleSidebar = Notification.Name("toggleSidebar")
}
