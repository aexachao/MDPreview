import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?
    private var statusBarController: StatusBarController?
    private let settingsManager = SettingsManager.shared

    // Store all window controllers to prevent them from being deallocated
    private var windowControllers: [MainWindowController] = []

    // Store files to open when app is ready (openFiles called before didFinishLaunching)
    private var pendingFilesToOpen: [URL] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupStatusBar()
        settingsManager.applyInitialSettings()

        mainWindowController = MainWindowController()
        mainWindowController?.showWindow(nil)

        // Process any files that were passed before launch
        if !pendingFilesToOpen.isEmpty {
            // Delay to ensure toolbar is fully loaded
            DispatchQueue.main.async {
                for url in self.pendingFilesToOpen {
                    self.mainWindowController?.loadFileNow(url: url)
                }
                self.pendingFilesToOpen.removeAll()
            }
        }

        // Ensure app is activated and window is key
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            self.mainWindowController?.showWindow(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map { URL(fileURLWithPath: $0) }
        let mdFiles = urls.filter {
            $0.pathExtension.lowercased() == "md" || $0.pathExtension.lowercased() == "markdown"
        }

        if mainWindowController != nil {
            // App is already initialized, create new window for each file
            for url in mdFiles {
                let newController = MainWindowController()
                windowControllers.append(newController)
                newController.showWindow(nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    newController.openFile(at: url)
                }
            }
        } else {
            // App not yet initialized, store files to process later
            pendingFilesToOpen.append(contentsOf: mdFiles)
        }
        NSApp.reply(toOpenOrPrint: .success)
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statusBarVisibilityChanged(_:)),
            name: .statusBarVisibilityChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSettings(_:)),
            name: .showSettings,
            object: nil
        )
    }

    @objc private func statusBarVisibilityChanged(_ notification: Notification) {
        if let show = notification.object as? Bool {
            if show {
                statusBarController?.show()
            } else {
                statusBarController?.hide()
            }
        }
    }

    private func setupMenuBar() {
        let s = Strings.shared
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(withTitle: s.aboutApp, action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: s.settings, action: #selector(showSettings(_:)), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: s.quitApp, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: s.file)
        fileMenuItem.submenu = fileMenu

        let openItem = NSMenuItem(title: s.open, action: #selector(openDocument(_:)), keyEquivalent: "o")
        openItem.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        fileMenu.addItem(openItem)

        let newWindowItem = NSMenuItem(title: s.newWindow, action: #selector(newWindow(_:)), keyEquivalent: "n")
        newWindowItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        fileMenu.addItem(newWindowItem)

        fileMenu.addItem(NSMenuItem.separator())

        let closeItem = NSMenuItem(title: s.close, action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        fileMenu.addItem(closeItem)

        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: s.edit)
        editMenuItem.submenu = editMenu

        editMenu.addItem(withTitle: s.copy, action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: s.selectAll, action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // View menu
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        let viewMenu = NSMenu(title: s.view)
        viewMenuItem.submenu = viewMenu

        viewMenu.addItem(withTitle: s.enterFullScreen, action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")

        // Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: s.window)
        windowMenuItem.submenu = windowMenu

        windowMenu.addItem(withTitle: s.minimize, action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: s.zoom, action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")

        NSApplication.shared.mainMenu = mainMenu
        NSApplication.shared.windowsMenu = windowMenu
    }

    private func setupStatusBar() {
        statusBarController = StatusBarController()

        statusBarController?.onShowWindow = { [weak self] in
            self?.mainWindowController?.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
        }

        statusBarController?.onOpenFile = { [weak self] in
            self?.openDocument(nil)
        }

        statusBarController?.onNewWindow = { [weak self] in
            self?.newWindow(nil)
        }

        statusBarController?.onShowSettings = { [weak self] in
            self?.showSettings(nil)
        }

        statusBarController?.onQuit = {
            NSApplication.shared.terminate(nil)
        }
    }

    @objc func openDocument(_ sender: Any?) {
        // Create a new window controller for each file
        let newController = MainWindowController()
        windowControllers.append(newController)
        newController.showWindow(nil)
        // Delay openFile to ensure window and toolbar are fully loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            newController.openFile()
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func newWindow(_ sender: Any?) {
        let newController = MainWindowController()
        newController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showSettings(_ sender: Any?) {
        // Always create a new settings window to avoid lifecycle issues
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = Strings.shared.settings
        settingsWindow.center()
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
