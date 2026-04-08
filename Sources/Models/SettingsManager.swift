import Foundation
import AppKit
import ServiceManagement

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let hideDockIcon = "hideDockIcon"
        static let showStatusBarIcon = "showStatusBarIcon"
        static let locale = "locale"
    }

    enum Locale: String, CaseIterable {
        case system = "system"
        case english = "en"
        case chinese = "zh"

        var displayName: String {
            switch self {
            case .system: return String(localized: "跟随系统")
            case .english: return "English"
            case .chinese: return "中文"
            }
        }
    }

    var onDockIconVisibilityChanged: (() -> Void)?

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLoginItem()
        }
    }

    @Published var hideDockIcon: Bool {
        didSet {
            defaults.set(hideDockIcon, forKey: Keys.hideDockIcon)
            updateDockIconVisibility()
        }
    }

    @Published var showStatusBarIcon: Bool {
        didSet {
            defaults.set(showStatusBarIcon, forKey: Keys.showStatusBarIcon)
        }
    }

    @Published var locale: Locale {
        didSet {
            defaults.set(locale.rawValue, forKey: Keys.locale)
            applyLocale()
        }
    }

    private init() {
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.hideDockIcon = defaults.bool(forKey: Keys.hideDockIcon)
        self.showStatusBarIcon = defaults.object(forKey: Keys.showStatusBarIcon) as? Bool ?? true

        let localeRaw = defaults.string(forKey: Keys.locale) ?? Locale.system.rawValue
        self.locale = Locale(rawValue: localeRaw) ?? .system

        applyLocale()
    }

    private func updateLoginItem() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update login item: \(error)")
            }
        } else {
            let success = SMLoginItemSetEnabled("com.mdpreview.app" as CFString, launchAtLogin)
            if !success {
                print("Failed to update login item")
            }
        }
    }

    private func updateDockIconVisibility() {
        // Note: NSApp.setActivationPolicy(.accessory) makes windows unable to become key
        // For apps with windows, this is problematic. The Dock icon visibility is
        // controlled by macOS and cannot be changed at runtime for regular apps.
        // We keep the app in .regular mode to ensure windows work properly.
        if !hideDockIcon {
            NSApp.setActivationPolicy(.regular)
        }
        // Notify app to restore window focus
        onDockIconVisibilityChanged?()
    }

    func applyInitialSettings() {
        // Always start in regular mode so window can be displayed
        NSApp.setActivationPolicy(.regular)
        if launchAtLogin {
            updateLoginItem()
        }
    }

    private func applyLocale() {
        let languages: [String]?
        switch locale {
        case .system:
            // When following system, don't modify AppleLanguages
            // Remove the key to let system use its default
            defaults.removeObject(forKey: "AppleLanguages")
            return
        case .english:
            languages = ["en"]
        case .chinese:
            languages = ["zh"]
        }
        defaults.set(languages, forKey: "AppleLanguages")
    }
}
