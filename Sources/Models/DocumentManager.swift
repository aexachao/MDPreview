import Foundation
import Combine

struct OutlineItem: Identifiable, Hashable {
    let id = UUID()
    let level: Int
    let title: String
    let anchor: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
        lhs.id == rhs.id
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
                    let anchor = title.lowercased()
                        .replacingOccurrences(of: " ", with: "-")

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
