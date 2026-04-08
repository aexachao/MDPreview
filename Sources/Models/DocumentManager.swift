import Foundation
import Combine

struct OutlineItem: Identifiable, Hashable {
    let id: String  // Use anchor as id for proper comparison
    let level: Int
    let title: String
    let anchor: String

    init(level: Int, title: String, anchor: String) {
        self.id = anchor  // Use anchor as id
        self.level = level
        self.title = title
        self.anchor = anchor
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(anchor)
    }

    static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
        lhs.anchor == rhs.anchor
    }
}

class DocumentManager: ObservableObject {
    @Published var currentFileURL: URL?
    @Published var markdownContent: String = ""
    @Published var renderedHTML: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var outlineItems: [OutlineItem] = []
    @Published var selectedOutlineItem: OutlineItem?
    @Published var pendingScrollToAnchor: String?

    private let renderer = MarkdownRenderer()

    func loadFile(url: URL) {
        isLoading = true
        errorMessage = nil
        outlineItems = []
        selectedOutlineItem = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    self?.currentFileURL = url
                    self?.markdownContent = content
                    self?.parseOutline(from: content)
                    self?.renderMarkdown(content)
                    self?.isLoading = false
                }
            } catch {
                do {
                    let content = try String(contentsOf: url, encoding: .isoLatin1)
                    DispatchQueue.main.async {
                        self?.currentFileURL = url
                        self?.markdownContent = content
                        self?.parseOutline(from: content)
                        self?.renderMarkdown(content)
                        self?.isLoading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Unable to read file"
                        self?.isLoading = false
                    }
                }
            }
        }
    }

    private func parseOutline(from markdown: String) {
        var items: [OutlineItem] = []
        let lines = markdown.components(separatedBy: CharacterSet.newlines)
        var anchorCounts: [String: Int] = [:]

        for line in lines {
            let trimmed = line.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmed.hasPrefix("#") {
                var level = 0
                var title = trimmed

                for char in trimmed {
                    if char == "#" {
                        level += 1
                    } else {
                        break
                    }
                }

                if level > 0 && level <= 6 {
                    title = String(trimmed.dropFirst(level)).trimmingCharacters(in: CharacterSet.whitespaces)
                    // Only replace spaces with hyphens, keep all other characters including Chinese
                    let baseAnchor = title.lowercased()
                        .replacingOccurrences(of: " ", with: "-")

                    // Handle duplicate anchors by adding index
                    var anchor = baseAnchor
                    if let count = anchorCounts[baseAnchor] {
                        anchorCounts[baseAnchor] = count + 1
                        anchor = "\(baseAnchor)-\(count)"
                    } else {
                        anchorCounts[baseAnchor] = 1
                    }

                    items.append(OutlineItem(level: level, title: title, anchor: anchor))
                }
            }
        }

        outlineItems = items
    }

    private func renderMarkdown(_ content: String) {
        if content.isEmpty {
            renderedHTML = "<html><body><p style='color: #666; font-style: italic;'>This file is empty.</p></body></html>"
            return
        }

        do {
            renderedHTML = try renderer.renderToHTML(content)
        } catch {
            renderedHTML = "<html><body><p style='color: #d73a49;'>Error rendering markdown</p></body></html>"
        }
    }
}
