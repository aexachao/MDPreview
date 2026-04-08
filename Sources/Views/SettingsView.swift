import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State private var showRestartAlert = false
    @State private var pendingLocale: SettingsManager.Locale = .system

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker(Strings.shared.language, selection: $settingsManager.locale) {
                        ForEach(SettingsManager.Locale.allCases, id: \.self) { locale in
                            Text(locale.displayName).tag(locale)
                        }
                    }
                    .onChange(of: settingsManager.locale) { newValue in
                        pendingLocale = newValue
                        showRestartAlert = true
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

                    Text(Strings.shared.restartHint)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .frame(width: 400, height: 320)
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text(Strings.shared.languageChangedTitle),
                message: Text(Strings.shared.languageChangedMessage),
                primaryButton: .default(Text(Strings.shared.ok)) {
                    // Just close alert, user will restart manually
                },
                secondaryButton: .cancel()
            )
        }
    }
}

extension Notification.Name {
    static let statusBarVisibilityChanged = Notification.Name("statusBarVisibilityChanged")
}
