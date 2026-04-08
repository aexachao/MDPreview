import Foundation

/// 本地化字符串管理器
class Strings {
    static let shared = Strings()

    private init() {}

    private var isChinese: Bool {
        let defaults = UserDefaults.standard
        let localeRaw = defaults.string(forKey: "locale") ?? "system"

        switch localeRaw {
        case "zh":
            return true
        case "en":
            return false
        default: // system
            // Use preferredLanguages which directly reflects user's system language settings
            guard let preferredLanguage = Locale.preferredLanguages.first else {
                return false
            }
            // Check if Chinese (zh) is the primary language
            // This handles zh, zh-Hans, zh-Hant, zh-CN, zh-TW, etc.
            let languageCode = preferredLanguage.components(separatedBy: "-").first ?? preferredLanguage
            return languageCode == "zh"
        }
    }

    // MARK: - App

    var appName: String { isChinese ? "MDPreview" : "MDPreview" }
    var quitApp: String { isChinese ? "退出 MDPreview" : "Quit MDPreview" }
    var aboutApp: String { isChinese ? "关于 MDPreview" : "About MDPreview" }
    var showMainWindow: String { isChinese ? "显示主界面" : "Show Main Window" }
    var show: String { isChinese ? "显示" : "Show" }

    // MARK: - Menu

    var file: String { isChinese ? "文件" : "File" }
    var edit: String { isChinese ? "编辑" : "Edit" }
    var view: String { isChinese ? "视图" : "View" }
    var window: String { isChinese ? "窗口" : "Window" }
    var help: String { isChinese ? "帮助" : "Help" }

    var open: String { isChinese ? "打开..." : "Open..." }
    var newWindow: String { isChinese ? "新建窗口" : "New Window" }
    var close: String { isChinese ? "关闭" : "Close" }
    var settings: String { isChinese ? "设置..." : "Settings..." }
    var toggleSidebar: String { isChinese ? "显示/隐藏大纲" : "Show/Hide Outline" }

    var copy: String { isChinese ? "复制" : "Copy" }
    var selectAll: String { isChinese ? "全选" : "Select All" }

    var enterFullScreen: String { isChinese ? "进入全屏" : "Enter Full Screen" }
    var minimize: String { isChinese ? "最小化" : "Minimize" }
    var zoom: String { isChinese ? "缩放" : "Zoom" }

    // MARK: - Sidebar

    var outline: String { isChinese ? "大纲" : "Outline" }
    var noOutline: String { isChinese ? "无大纲" : "No Outline" }
    var showSidebar: String { isChinese ? "显示大纲" : "Show Outline" }
    var hideSidebar: String { isChinese ? "隐藏大纲" : "Hide Outline" }

    // MARK: - Settings

    var generalSettings: String { isChinese ? "通用设置" : "General" }
    var about: String { isChinese ? "关于" : "About" }
    var language: String { isChinese ? "语言" : "Language" }
    var launchAtLogin: String { isChinese ? "开机自启动" : "Launch at Login" }
    var stealthMode: String { isChinese ? "无痕模式" : "Stealth Mode" }
    var stealthModeDescription: String { isChinese ? "隐藏 Dock 图标，应用不显示在程序坞" : "Hides Dock icon, app won't appear in Dock" }
    var showStatusBarIcon: String { isChinese ? "显示状态栏图标" : "Show Status Bar Icon" }
    var version: String { isChinese ? "版本" : "Version" }
    var appDescription: String { isChinese ? "Markdown 文件预览工具" : "Markdown File Preview Tool" }

    // MARK: - Status Bar

    var openFile: String { isChinese ? "打开文件..." : "Open File..." }
    var quit: String { isChinese ? "退出" : "Quit" }

    // MARK: - Toolbar

    var toggleOutline: String { isChinese ? "显示/隐藏大纲" : "Show/Hide Outline" }
    var openFileTool: String { isChinese ? "打开" : "Open" }

    // MARK: - Errors

    var fileNotFound: String { isChinese ? "文件未找到" : "File Not Found" }
    var readError: String { isChinese ? "读取文件失败" : "Failed to Read File" }
    var emptyFile: String { isChinese ? "此文件为空" : "This file is empty." }
    var openMarkdownHint: String { isChinese ? "打开 Markdown 文件以预览" : "Open a Markdown file to preview" }
    var openFileButton: String { isChinese ? "打开文件" : "Open File" }
    var dragDropHint: String { isChinese ? "或拖放 .md 文件到这里" : "Or drag and drop a .md file here" }

    // MARK: - Restart Alert

    var languageChangedTitle: String { isChinese ? "语言已更改" : "Language Changed" }
    var languageChangedMessage: String { isChinese ? "语言更改需要重启应用才能生效。是否立即重启？" : "Language changes require restarting the app to take effect. Restart now?" }
    var restartNow: String { isChinese ? "立即重启" : "Restart Now" }
    var restartLater: String { isChinese ? "稍后" : "Later" }
    var restartHint: String { isChinese ? "语言更改将在重启应用后生效" : "Language changes will take effect after restarting the app" }
}
