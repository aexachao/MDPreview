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
                        Text("\(Strings.shared.version): \(appVersion)")
                            .foregroundColor(.secondary)
                        Text("MDPreview - \(Strings.shared.appDescription)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(Strings.shared.about)
                        .font(.headline)
                        .padding(.top, 12)
                }
            }
            .padding(20)
        }
        .frame(width: 400, height: 280)
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text(Strings.shared.languageChangedTitle),
                message: Text(Strings.shared.languageChangedMessage),
                primaryButton: .default(Text(Strings.shared.restartNow)) {
                    restartApp()
                },
                secondaryButton: .cancel(Text(Strings.shared.restartLater))
            )
        }
    }

    private func restartApp() {
        let bundlePath = Bundle.main.bundlePath

        // Launch new instance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSWorkspace.shared.open(URL(fileURLWithPath: bundlePath))
            NSApp.terminate(nil)
        }
    }

    private var appVersion: String {
        // Read version from VERSION file in bundle
        guard let versionFile = Bundle.main.url(forResource: "VERSION", withExtension: nil),
              let version = try? String(contentsOf: versionFile, encoding: .utf8) else {
            // Fallback to Info.plist if VERSION file not found
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }
        return version.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Notification.Name {
    static let statusBarVisibilityChanged = Notification.Name("statusBarVisibilityChanged")
}
