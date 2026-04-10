import Foundation

class MarkdownRenderer {
    enum RendererError: Error {
        case renderingFailed
    }

    func renderToHTML(_ markdown: String) throws -> String {
        // Escape JavaScript special characters in markdown
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")

        // Load marked.js from bundle
        var markedJS = ""
        if let jsPath = Bundle.main.path(forResource: "marked.min", ofType: "js") {
            markedJS = (try? String(contentsOfFile: jsPath, encoding: .utf8)) ?? ""
        }

        // Load heading renderer from bundle
        var headingRendererJS = ""
        if let jsPath = Bundle.main.path(forResource: "heading-renderer", ofType: "js") {
            headingRendererJS = (try? String(contentsOfFile: jsPath, encoding: .utf8)) ?? ""
        }

        return wrapWithStyle(escapedMarkdown, markedJS: markedJS, headingRendererJS: headingRendererJS)
    }

    private func wrapWithStyle(_ markdown: String, markedJS: String, headingRendererJS: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                :root {
                    --bg-color: #ffffff;
                    --text-color: #24292e;
                    --code-bg: #f6f8fa;
                    --code-border: #e1e4e8;
                    --blockquote-border: #d1d5da;
                    --link-color: #0366d6;
                    --table-border: #dfe2e5;
                    --heading-color: #1a1a1a;
                }

                @media (prefers-color-scheme: dark) {
                    :root {
                        --bg-color: #0d1117;
                        --text-color: #c9d1d9;
                        --code-bg: #1e1e1e;
                        --code-border: #30363d;
                        --blockquote-border: #30363d;
                        --link-color: #58a6ff;
                        --table-border: #30363d;
                        --heading-color: #f0f0f0;
                    }
                }

                * {
                    box-sizing: border-box;
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                    font-size: 15px;
                    line-height: 1.6;
                    color: var(--text-color);
                    background-color: var(--bg-color);
                    padding: 16px 24px;
                    margin: 0;
                    width: 100%;
                    max-width: 100%;
                    overflow-x: hidden;
                }

                .content {
                    max-width: 800px;
                    margin: 0 auto;
                }

                h1, h2, h3, h4, h5, h6 {
                    color: var(--heading-color);
                    margin-top: 24px;
                    margin-bottom: 12px;
                    font-weight: 600;
                    line-height: 1.25;
                }

                h1 { font-size: 28px; border-bottom: 1px solid var(--code-border); padding-bottom: 8px; }
                h2 { font-size: 24px; border-bottom: 1px solid var(--code-border); padding-bottom: 6px; }
                h3 { font-size: 20px; }
                h4 { font-size: 16px; }
                h5 { font-size: 14px; }
                h6 { font-size: 13px; color: #6a737d; }

                p {
                    margin-top: 0;
                    margin-bottom: 16px;
                }

                a {
                    color: var(--link-color);
                    text-decoration: none;
                }

                a:hover {
                    text-decoration: underline;
                }

                code {
                    font-family: "SF Mono", SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
                    font-size: 13px;
                    background-color: var(--code-bg);
                    padding: 2px 6px;
                    border-radius: 4px;
                    border: 1px solid var(--code-border);
                }

                pre {
                    background-color: var(--code-bg);
                    border: 1px solid var(--code-border);
                    border-radius: 6px;
                    padding: 16px;
                    overflow-x: auto;
                    line-height: 1.45;
                    margin: 16px 0;
                }

                pre code {
                    background-color: transparent;
                    border: none;
                    padding: 0;
                    font-size: 13px;
                }

                blockquote {
                    margin: 0;
                    padding: 0 16px;
                    color: #6a737d;
                    border-left: 4px solid var(--blockquote-border);
                }

                ul, ol {
                    padding-left: 24px;
                    margin: 16px 0;
                }

                li {
                    margin: 4px 0;
                }

                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: 16px 0;
                    border: 1px solid var(--table-border);
                }

                table th, table td {
                    border: 1px solid var(--table-border);
                    padding: 8px 12px;
                    text-align: left;
                }

                table th {
                    background-color: var(--code-bg);
                    font-weight: 600;
                }

                hr {
                    border: none;
                    border-top: 1px solid var(--code-border);
                    margin: 24px 0;
                }

                img {
                    max-width: 100%;
                    height: auto;
                }
            </style>
        </head>
        <body>
            <div id="content" class="content"></div>
            <script>
                \(markedJS)
                \(headingRendererJS)
                var markdownStr = `\(markdown)`;
                document.getElementById('content').innerHTML = marked.parse(markdownStr);
            </script>
        </body>
        </html>
        """
    }
}
