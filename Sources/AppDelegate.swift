import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?
    private var statusBarController: StatusBarController?
    private var settingsWindowController: NSWindow?
    private let settingsManager = SettingsManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupStatusBar()
        settingsManager.applyInitialSettings()

        mainWindowController = MainWindowController()
        mainWindowController?.showWindow(nil)

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
        for url in urls {
            if url.pathExtension.lowercased() == "md" || url.pathExtension.lowercased() == "markdown" {
                if mainWindowController == nil {
                    mainWindowController = MainWindowController()
                }
                mainWindowController?.openFile(at: url)
                mainWindowController?.showWindow(nil)
            }
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

        // Setup dock icon visibility change callback
        settingsManager.onDockIconVisibilityChanged = { [weak self] in
            self?.restoreWindowFocus()
        }
    }

    private func restoreWindowFocus() {
        // If hideDockIcon is true (accessory mode), we can't really bring window to front properly
        // But if it's false (regular mode), we should restore focus
        if !settingsManager.hideDockIcon {
            mainWindowController?.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
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
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(withTitle: "关于 MDPreview", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "设置...", action: #selector(showSettings(_:)), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "退出 MDPreview", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "文件")
        fileMenuItem.submenu = fileMenu

        let openItem = NSMenuItem(title: "打开...", action: #selector(openDocument(_:)), keyEquivalent: "o")
        openItem.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
        fileMenu.addItem(openItem)

        let newWindowItem = NSMenuItem(title: "新建窗口", action: #selector(newWindow(_:)), keyEquivalent: "n")
        newWindowItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        fileMenu.addItem(newWindowItem)

        fileMenu.addItem(NSMenuItem.separator())

        let closeItem = NSMenuItem(title: "关闭", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        fileMenu.addItem(closeItem)

        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "编辑")
        editMenuItem.submenu = editMenu

        editMenu.addItem(withTitle: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // View menu
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        let viewMenu = NSMenu(title: "视图")
        viewMenuItem.submenu = viewMenu

        viewMenu.addItem(withTitle: "进入全屏", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")

        // Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "窗口")
        windowMenuItem.submenu = windowMenu

        windowMenu.addItem(withTitle: "最小化", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "缩放", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")

        NSApplication.shared.mainMenu = mainMenu
        NSApplication.shared.windowsMenu = windowMenu
    }

    private func setupStatusBar() {
        statusBarController = StatusBarController()

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
        if mainWindowController == nil {
            mainWindowController = MainWindowController()
        }
        mainWindowController?.openFile()
        mainWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func newWindow(_ sender: Any?) {
        let newController = MainWindowController()
        newController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showSettings(_ sender: Any?) {
        if settingsWindowController == nil {
            let settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 220),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow.title = "设置"
            settingsWindow.center()
            settingsWindow.contentView = NSHostingView(rootView: SettingsView())
            settingsWindow.isReleasedWhenClosed = false
            settingsWindow.delegate = self
            settingsWindowController = settingsWindow
        }
        settingsWindowController?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindowController {
            settingsWindowController = nil
        }
    }
}
