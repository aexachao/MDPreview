import Foundation

/// 本地化字符串管理器
class Strings {
    static let shared = Strings()

    private init() {}

    private var isChinese: Bool {
        // Direct access to UserDefaults to avoid timing issues with SettingsManager initialization
        let defaults = UserDefaults.standard
        let localeRaw = defaults.string(forKey: "locale") ?? "system"
        switch localeRaw {
        case "zh":
            return true
        case "en":
            return false
        default: // system
            return Locale.preferredLanguages.first?.hasPrefix("zh") == true
        }
    }

    // MARK: - App

    var appName: String { isChinese ? "MDPreview" : "MDPreview" }
    var quitApp: String { isChinese ? "退出 MDPreview" : "Quit MDPreview" }
    var aboutApp: String { isChinese ? "关于 MDPreview" : "About MDPreview" }

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
    var hideDockIcon: String { isChinese ? "隐藏 Dock 图标" : "Hide Dock Icon" }
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

    // MARK: - Restart Alert

    var languageChangedTitle: String { isChinese ? "语言已更改" : "Language Changed" }
    var languageChangedMessage: String { isChinese ? "语言更改需要重启应用才能生效。请手动关闭并重新打开应用。" : "Language changes require restarting the app to take effect. Please manually close and reopen the app." }
    var restartHint: String { isChinese ? "语言更改将在重启应用后生效" : "Language changes will take effect after restarting the app" }
    var ok: String { isChinese ? "确定" : "OK" }
}
