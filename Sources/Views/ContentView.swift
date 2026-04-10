import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var sidebarVisible = false
    @State private var windowWidth: CGFloat = 1200
    let windowId: Int

    // Track if user manually toggled sidebar
    @State private var userManuallyToggled = false

    // Auto restore threshold - when window is wide enough, re-enable auto mode
    private let autoRestoreThreshold: CGFloat = 1200

    // Threshold = content max-width (800) + sidebar width (250) + divider (1)
    private let sidebarCollapseThreshold: CGFloat = 1100

    init(documentManager: DocumentManager, windowId: Int = 0) {
        self.documentManager = documentManager
        self.windowId = windowId
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                SidebarView(
                    documentManager: documentManager,
                    selectedOutline: Binding(
                        get: { documentManager.selectedOutlineItem },
                        set: { newValue in
                            documentManager.selectedOutlineItem = newValue
                            if let item = newValue {
                                documentManager.pendingScrollToAnchor = item.anchor
                            }
                        }
                    )
                )
                .frame(width: sidebarVisible ? 250 : 0, height: nil)
                .clipped()

                if sidebarVisible {
                    Divider()
                        .frame(width: 1)
                }

                ZStack {
                    Group {
                        if let error = documentManager.errorMessage {
                            ErrorView(message: error)
                        } else if documentManager.currentFileURL == nil {
                            EmptyStateView {
                                openFile()
                            }
                        } else if documentManager.markdownContent.isEmpty {
                            EmptyMarkdownView()
                        } else {
                            MarkdownWebView(
                                html: documentManager.renderedHTML,
                                scrollToAnchor: documentManager.pendingScrollToAnchor,
                                onVisibleHeadingChange: { [documentManager] anchor in
                                    guard let anchor = anchor,
                                          let item = documentManager.outlineItems.first(where: { $0.anchor == anchor }) else { return }
                                    if documentManager.pendingScrollToAnchor == anchor {
                                        documentManager.pendingScrollToAnchor = nil
                                    }
                                    if documentManager.pendingScrollToAnchor == nil {
                                        documentManager.selectedOutlineItem = item
                                    }
                                }
                            )
                            .frame(minWidth: 400, maxWidth: .infinity, alignment: .center)
                            .id(documentManager.currentFileURL?.absoluteString ?? "")
                        }
                    }

                    if documentManager.currentFileURL == nil {
                        EmptyDropZone { url in
                            documentManager.loadFile(url: url)
                        }
                    }
                }
                .frame(minWidth: 400, alignment: .center)
            }
            .animation(.easeInOut(duration: 0.25), value: sidebarVisible)
            .frame(minWidth: 800, minHeight: 600)
            .onAppear {
                setupNotificationObservers()
            }
            .onChange(of: documentManager.currentFileURL) { _ in
                // When document changes, reset to auto mode and update sidebar visibility based on window width
                userManuallyToggled = false
                sidebarVisible = windowWidth >= sidebarCollapseThreshold && documentManager.currentFileURL != nil
            }
            .onChange(of: geometry.size.width) { newWidth in
                windowWidth = newWidth
                updateSidebarForWidth(newWidth)
            }
        }
    }

    private func updateSidebarForWidth(_ width: CGFloat) {
        // Auto restore: when window is wide enough, re-enable auto mode
        if width >= autoRestoreThreshold {
            userManuallyToggled = false
        }

        if userManuallyToggled {
            // User manually toggled, don't override their choice
            return
        }

        let shouldShow = width >= sidebarCollapseThreshold && documentManager.currentFileURL != nil
        sidebarVisible = shouldShow
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .toggleSidebar,
            object: nil,
            queue: .main
        ) { [self] notification in
            if let notificationWindowId = notification.object as? Int, notificationWindowId == windowId {
                sidebarVisible.toggle()
                userManuallyToggled = true
            }
        }
    }

    private func openFile() {
        if let window = NSApplication.shared.mainWindow {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.init(filenameExtension: "md")!]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true

            panel.beginSheetModal(for: window) { response in
                if response == .OK, let url = panel.url {
                    documentManager.loadFile(url: url)
                }
            }
        }
    }
}

struct SidebarView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var selectedOutline: OutlineItem?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Strings.shared.outline)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if documentManager.outlineItems.isEmpty {
                VStack {
                    Spacer()
                    Text(Strings.shared.noOutline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(documentManager.outlineItems) { item in
                            OutlineRow(item: item, isSelected: selectedOutline?.id == item.id)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selectedOutline?.id == item.id ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedOutline = item
                                    documentManager.pendingScrollToAnchor = item.anchor
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct OutlineRow: View {
    let item: OutlineItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(item.title)
                .font(.system(size: fontSize))
                .fontWeight(item.level <= 2 ? .medium : .regular)
                .foregroundColor(isSelected ? .accentColor : (item.level <= 2 ? .primary : .secondary))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, CGFloat((item.level - 1) * 12))
    }

    private var fontSize: CGFloat {
        switch item.level {
        case 1: return 14
        case 2: return 13
        default: return 12
        }
    }
}

struct EmptyDropZone: NSViewRepresentable {
    let onDrop: (URL) -> Void

    func makeNSView(context: Context) -> DropZoneNSView {
        let view = DropZoneNSView()
        view.onDrop = onDrop
        return view
    }

    func updateNSView(_ nsView: DropZoneNSView, context: Context) {
        nsView.onDrop = onDrop
    }
}

class DropZoneNSView: NSView {
    var onDrop: ((URL) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if hasValidFileURL(sender) {
            return .copy
        }
        return []
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }

        for url in urls {
            if url.pathExtension.lowercased() == "md" || url.pathExtension.lowercased() == "markdown" {
                onDrop?(url)
                return true
            }
        }
        return false
    }

    private func hasValidFileURL(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }
        return urls.contains { $0.pathExtension.lowercased() == "md" || $0.pathExtension.lowercased() == "markdown" }
    }
}

extension Notification.Name {
    static let showSettings = Notification.Name("showSettings")
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(message)
                .font(.headline)
        }
    }
}

struct EmptyMarkdownView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(Strings.shared.emptyFile)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
