import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker(Strings.shared.language, selection: $settingsManager.locale) {
                        ForEach(SettingsManager.Locale.allCases, id: \.self) { locale in
                            Text(locale.displayName).tag(locale)
                        }
                    }

                    Toggle(Strings.shared.launchAtLogin, isOn: $settingsManager.launchAtLogin)
                        .toggleStyle(.switch)

                    Toggle(Strings.shared.hideDockIcon, isOn: $settingsManager.hideDockIcon)
                        .toggleStyle(.switch)

                    Toggle(Strings.shared.showStatusBarIcon, isOn: $settingsManager.showStatusBarIcon)
                        .toggleStyle(.switch)
                        .onChange(of: settingsManager.showStatusBarIcon) { newValue in
                            NotificationCenter.default.post(name: .statusBarVisibilityChanged, object: newValue)
                        }
                } header: {
                    Text(Strings.shared.generalSettings)
                        .font(.headline)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(Strings.shared.version): 1.0.6")
                            .foregroundColor(.secondary)
                        Text("MDPreview - \(Strings.shared.appDescription)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(Strings.shared.about)
                        .font(.headline)
                }
            }
            .padding(20)
        }
        .frame(width: 400, height: 280)
    }
}

extension Notification.Name {
    static let statusBarVisibilityChanged = Notification.Name("statusBarVisibilityChanged")
}
