import SwiftUI
import AppKit

struct TitleBarView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var sidebarVisible: Bool
    @Binding var selectedOutline: OutlineItem?

    var onOpenFile: () -> Void
    var onShowSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // App name
            Text("MDPreview")
                .font(.headline)
                .foregroundColor(.primary)

            // Sidebar toggle
            Button(action: { withAnimation { sidebarVisible.toggle() } }) {
                Image(systemName: sidebarVisible ? "sidebar.left.fill" : "sidebar.left")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .help(sidebarVisible ? "隐藏大纲" : "显示大纲")

            Spacer()

            // Right side buttons
            HStack(spacing: 8) {
                Button(action: onShowSettings) {
                    Image(systemName: "gear")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help("设置")

                Button(action: onOpenFile) {
                    Image(systemName: "doc.text")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help("打开文件")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
