import AppKit
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem?
    private let settingsManager = SettingsManager.shared

    var onShowWindow: (() -> Void)?
    var onOpenFile: (() -> Void)?
    var onNewWindow: (() -> Void)?
    var onShowSettings: (() -> Void)?
    var onQuit: (() -> Void)?

    init() {
        setupStatusBar()
    }

    private func setupStatusBar() {
        if settingsManager.showStatusBarIcon {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: "MDPreview")
                button.image?.isTemplate = true
            }

            statusItem?.menu = createMenu()
        }
    }

    private func createMenu() -> NSMenu {
        let s = Strings.shared
        let menu = NSMenu()

        let showItem = NSMenuItem(title: s.show, action: #selector(showWindowAction), keyEquivalent: "")
        showItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let openItem = NSMenuItem(title: s.open, action: #selector(openFileAction), keyEquivalent: "o")
        openItem.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
        openItem.target = self
        menu.addItem(openItem)

        let newWindowItem = NSMenuItem(title: s.newWindow, action: #selector(newWindowAction), keyEquivalent: "n")
        newWindowItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        newWindowItem.target = self
        menu.addItem(newWindowItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: s.settings, action: #selector(showSettingsAction), keyEquivalent: ",")
        settingsItem.image = NSImage(systemSymbolName: "gear", accessibilityDescription: nil)
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: s.quitApp, action: #selector(quitAction), keyEquivalent: "q")
        quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    func updateMenu() {
        statusItem?.menu = createMenu()
    }

    func show() {
        if statusItem == nil && settingsManager.showStatusBarIcon {
            setupStatusBar()
        }
        statusItem?.isVisible = true
    }

    func hide() {
        statusItem?.isVisible = false
    }

    func remove() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    @objc private func showWindowAction() {
        onShowWindow?()
    }

    @objc private func openFileAction() {
        onOpenFile?()
    }

    @objc private func newWindowAction() {
        onNewWindow?()
    }

    @objc private func showSettingsAction() {
        onShowSettings?()
    }

    @objc private func quitAction() {
        onQuit?()
    }
}
