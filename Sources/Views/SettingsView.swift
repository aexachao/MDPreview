import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Toggle("开机自启动", isOn: $settingsManager.launchAtLogin)
                        .toggleStyle(.switch)

                    Toggle("隐藏 Dock 图标", isOn: $settingsManager.hideDockIcon)
                        .toggleStyle(.switch)

                    Toggle("显示状态栏图标", isOn: $settingsManager.showStatusBarIcon)
                        .toggleStyle(.switch)
                        .onChange(of: settingsManager.showStatusBarIcon) { newValue in
                            NotificationCenter.default.post(name: .statusBarVisibilityChanged, object: newValue)
                        }
                } header: {
                    Text("通用设置")
                        .font(.headline)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("版本: 1.0")
                            .foregroundColor(.secondary)
                        Text("MDPreview - Markdown 文件预览工具")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("关于")
                        .font(.headline)
                }
            }
            .padding(20)
        }
        .frame(width: 400, height: 220)
    }
}

extension Notification.Name {
    static let statusBarVisibilityChanged = Notification.Name("statusBarVisibilityChanged")
}
