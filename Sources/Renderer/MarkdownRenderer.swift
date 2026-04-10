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
                    position: relative;
                }

                h1 { font-size: 28px; border-bottom: 1px solid var(--code-border); padding-bottom: 8px; }
                h2 { font-size: 24px; border-bottom: 1px solid var(--code-border); padding-bottom: 6px; }
                h3 { font-size: 20px; }
                h4 { font-size: 16px; }
                h5 { font-size: 14px; }
                h6 { font-size: 13px; color: #6a737d; }

                /* Heading anchor link */
                .heading-anchor {
                    position: absolute;
                    left: -24px;
                    opacity: 0;
                    color: var(--link-color);
                    text-decoration: none;
                    font-weight: normal;
                    padding: 0 4px;
                }

                h1:hover .heading-anchor,
                h2:hover .heading-anchor,
                h3:hover .heading-anchor,
                h4:hover .heading-anchor,
                h5:hover .heading-anchor,
                h6:hover .heading-anchor {
                    opacity: 0.5;
                }

                .heading-anchor:hover {
                    opacity: 1 !important;
                    text-decoration: none;
                }

                p {
                    margin-top: 0;
                    margin-bottom: 16px;
                }

                a {
                    color: var(--link-color);
                    text-decoration: none;
                    position: relative;
                }

                a:hover {
                    text-decoration: underline;
                }

                /* Link tooltip showing URL */
                a[data-url]::after {
                    content: attr(data-url);
                    position: absolute;
                    bottom: 100%;
                    left: 50%;
                    transform: translateX(-50%);
                    background: var(--text-color);
                    color: var(--bg-color);
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 12px;
                    white-space: nowrap;
                    opacity: 0;
                    pointer-events: none;
                    transition: opacity 0.2s;
                    z-index: 100;
                }

                a[data-url]:hover::after {
                    opacity: 0.8;
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
                    position: relative;
                    background-color: var(--code-bg);
                    border: 1px solid var(--code-border);
                    border-radius: 6px;
                    padding: 16px;
                    padding-top: 40px;
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

                /* Copy button for code blocks */
                .copy-button {
                    position: absolute;
                    top: 8px;
                    right: 8px;
                    background: var(--code-border);
                    color: var(--text-color);
                    border: none;
                    border-radius: 4px;
                    padding: 4px 8px;
                    font-size: 12px;
                    cursor: pointer;
                    opacity: 0;
                    transition: opacity 0.2s;
                }

                pre:hover .copy-button {
                    opacity: 0.8;
                }

                .copy-button:hover {
                    opacity: 1 !important;
                }

                .copy-button.copied {
                    opacity: 1 !important;
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
                    cursor: pointer;
                    transition: opacity 0.2s;
                }

                img:hover {
                    opacity: 0.9;
                }

                /* Image lightbox */
                .lightbox {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.9);
                    z-index: 1000;
                    justify-content: center;
                    align-items: center;
                }

                .lightbox.active {
                    display: flex;
                }

                .lightbox img {
                    max-width: 90%;
                    max-height: 90%;
                    object-fit: contain;
                }

                .lightbox-close {
                    position: absolute;
                    top: 20px;
                    right: 20px;
                    color: white;
                    font-size: 30px;
                    cursor: pointer;
                    background: none;
                    border: none;
                    padding: 10px;
                }
            </style>
        </head>
        <body>
            <div id="content" class="content"></div>
            <div class="lightbox" id="lightbox">
                <button class="lightbox-close">&times;</button>
                <img id="lightbox-img" src="" alt="">
            </div>
            <script>
                \(markedJS)
                \(headingRendererJS)
                var markdownStr = `\(markdown)`;
                document.getElementById('content').innerHTML = marked.parse(markdownStr);

                // Add heading anchor links
                document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(function(heading) {
                    if (heading.id) {
                        var anchor = document.createElement('a');
                        anchor.className = 'heading-anchor';
                        anchor.href = '#' + heading.id;
                        anchor.textContent = '#';
                        heading.insertBefore(anchor, heading.firstChild);
                    }
                });

                // Add copy buttons to code blocks
                var copyText = 'Copy';
                var copiedText = 'Copied!';
                var copyTextCN = '复制';
                var copiedTextCN = '已复制!';

                // Detect system language
                var isChinese = false;
                try {
                    var lang = navigator.language || navigator.userLanguage || '';
                    isChinese = lang.toLowerCase().indexOf('zh') >= 0;
                } catch (e) {}

                copyText = isChinese ? copyTextCN : copyText;
                copiedText = isChinese ? copiedTextCN : copiedText;

                document.querySelectorAll('pre').forEach(function(pre) {
                    var button = document.createElement('button');
                    button.className = 'copy-button';
                    button.textContent = copyText;
                    pre.appendChild(button);

                    button.addEventListener('click', function(e) {
                        e.stopPropagation();
                        var code = pre.querySelector('code');
                        if (code) {
                            var text = code.textContent || '';
                            // Try modern clipboard API first
                            if (navigator.clipboard && navigator.clipboard.writeText) {
                                navigator.clipboard.writeText(text).then(function() {
                                    showCopied(button);
                                }).catch(function() {
                                    fallbackCopy(text, button);
                                });
                            } else {
                                fallbackCopy(text, button);
                            }
                        }
                    });
                });

                function showCopied(button) {
                    button.textContent = copiedText;
                    button.classList.add('copied');
                    // After 2s, remove class to start fade, then change text after fade completes
                    setTimeout(function() {
                        button.classList.remove('copied');
                        // Change text back after opacity transition (200ms)
                        setTimeout(function() {
                            button.textContent = copyText;
                        }, 200);
                    }, 1800);
                }

                function fallbackCopy(text, button) {
                    var textarea = document.createElement('textarea');
                    textarea.value = text;
                    textarea.style.position = 'fixed';
                    textarea.style.opacity = '0';
                    document.body.appendChild(textarea);
                    textarea.select();
                    try {
                        document.execCommand('copy');
                        showCopied(button);
                    } catch (err) {
                        button.textContent = 'Failed';
                        setTimeout(function() {
                            button.textContent = copyText;
                            button.classList.remove('copied');
                        }, 2000);
                    }
                    document.body.removeChild(textarea);
                }

                // Add data-url attribute to links for tooltip
                document.querySelectorAll('a[href]').forEach(function(link) {
                    var href = link.getAttribute('href');
                    if (href && !href.startsWith('#') && !href.startsWith('javascript:')) {
                        link.setAttribute('data-url', href);
                    }
                });

                // Image lightbox
                var lightbox = document.getElementById('lightbox');
                var lightboxImg = document.getElementById('lightbox-img');

                document.querySelectorAll('img').forEach(function(img) {
                    img.addEventListener('click', function() {
                        lightboxImg.src = img.src;
                        lightbox.classList.add('active');
                    });
                });

                lightbox.addEventListener('click', function(e) {
                    if (e.target === lightbox || e.target.classList.contains('lightbox-close')) {
                        lightbox.classList.remove('active');
                    }
                });
            </script>
        </body>
        </html>
        """
    }
}
