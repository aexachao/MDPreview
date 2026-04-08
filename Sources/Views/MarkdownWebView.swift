import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    var scrollToAnchor: String?
    var onVisibleHeadingChange: ((String?) -> Void)?

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView

        // Add script message handler for scroll events
        webView.configuration.userContentController.add(context.coordinator, name: "visibleHeading")

        // Inject scroll observer script
        let scrollScript = WKUserScript(
            source: scrollObserverScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(scrollScript)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.onVisibleHeadingChange = onVisibleHeadingChange

        // Only reload HTML if content changed (new file loaded)
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            context.coordinator.pendingAnchor = scrollToAnchor
            webView.loadHTMLString(html, baseURL: nil)
        } else if let anchor = scrollToAnchor, anchor != context.coordinator.pendingAnchor {
            // HTML didn't change, but scrollToAnchor did (user clicked sidebar) - scroll to the anchor
            context.coordinator.pendingAnchor = anchor
            context.coordinator.scrollToAnchor(anchor, in: webView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private var scrollObserverScript: String {
        """
        (function() {
            var lastSentHeading = null;
            var lastScrollY = 0;
            var isInitialized = false;

            // Get all heading elements
            function getAllHeadings() {
                return document.querySelectorAll('h1, h2, h3, h4, h5, h6');
            }

            // Find heading closest to top of viewport
            function getHeadingAtTop() {
                var headings = getAllHeadings();
                if (headings.length === 0) return null;

                var viewportHeight = window.innerHeight;
                var topThreshold = viewportHeight * 0.35; // Top 35% of viewport
                var bestHeading = null;
                var bestTop = Infinity;

                for (var i = 0; i < headings.length; i++) {
                    var heading = headings[i];
                    if (!heading.id) continue;

                    var rect = heading.getBoundingClientRect();
                    // Heading must be in top portion of viewport (0 to 35% from top)
                    if (rect.top >= 0 && rect.top <= topThreshold) {
                        var score = Math.abs(rect.top);
                        if (score < bestTop) {
                            bestTop = score;
                            bestHeading = heading.id;
                        }
                    }
                }
                return bestHeading;
            }

            function sendHeading(heading) {
                if (heading && heading !== lastSentHeading) {
                    lastSentHeading = heading;
                    window.webkit.messageHandlers.visibleHeading.postMessage(heading);
                }
            }

            function onScroll() {
                if (!isInitialized) return;

                var scrollY = window.pageYOffset;
                var isScrollingDown = scrollY > lastScrollY;
                lastScrollY = scrollY;

                var heading = getHeadingAtTop();
                sendHeading(heading);
            }

            // Throttled scroll handler - 16ms for ~60fps responsiveness
            var scrollTimeout = null;
            window.addEventListener('scroll', function() {
                if (scrollTimeout) clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(onScroll, 16);
            }, {passive: true});

            // Initialize
            setTimeout(function() {
                isInitialized = true;
                lastScrollY = window.pageYOffset;
                var heading = getHeadingAtTop();
                sendHeading(heading);
            }, 500);
        })();
        """
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MarkdownWebView
        weak var webView: WKWebView?
        var pendingAnchor: String?
        var onVisibleHeadingChange: ((String?) -> Void)?
        var lastHTML: String = ""
        private var isInitialScrollDone = false

        init(_ parent: MarkdownWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "visibleHeading", let headingId = message.body as? String? {
                DispatchQueue.main.async { [weak self] in
                    self?.onVisibleHeadingChange?(headingId)
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               url.scheme == "https" || url.scheme == "http" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isInitialScrollDone = false
            if let anchor = pendingAnchor, !anchor.isEmpty {
                scrollToAnchor(anchor, in: webView)
                pendingAnchor = nil
            }
        }

        func scrollToAnchor(_ anchor: String, in webView: WKWebView) {
            let script = """
            (function() {
                var element = document.getElementById('\(anchor)');
                if (element) {
                    element.scrollIntoView({behavior: 'instant', block: 'start'});
                    return true;
                }
                return false;
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
