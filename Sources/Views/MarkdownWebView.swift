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
        // Only reload HTML if content changed (new file loaded)
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            context.coordinator.pendingAnchor = scrollToAnchor
            context.coordinator.onVisibleHeadingChange = onVisibleHeadingChange
            // Reset JS state by reloading - script will reinitialize automatically
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            // Just update the callback reference, don't reload
            context.coordinator.onVisibleHeadingChange = onVisibleHeadingChange
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

            // Get all heading elements and calculate content bottom for each
            function buildHeadingMap() {
                var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
                var map = [];

                for (var i = 0; i < headings.length; i++) {
                    var heading = headings[i];
                    if (!heading.id) continue;

                    var rect = heading.getBoundingClientRect();
                    var headingTop = rect.top;

                    // Content bottom is either the next heading's top, or document bottom
                    var contentBottom;
                    if (i < headings.length - 1) {
                        var nextHeading = headings[i + 1];
                        var nextRect = nextHeading.getBoundingClientRect();
                        contentBottom = nextRect.top;
                    } else {
                        // Last heading: content goes to document end
                        contentBottom = document.body.scrollHeight;
                    }

                    map.push({
                        id: heading.id,
                        headingTop: headingTop,
                        contentBottom: contentBottom,
                        level: heading.tagName
                    });
                }

                return map;
            }

            function getVisibleHeading() {
                var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
                if (headings.length === 0) return null;

                var scrollY = window.pageYOffset;
                var isScrollingDown = scrollY > lastScrollY;
                lastScrollY = scrollY;

                var viewportHeight = window.innerHeight;
                var map = buildHeadingMap();

                // Scrolling DOWN: current heading's content bottom reaches viewport top
                // -> switch to NEXT heading
                if (isScrollingDown) {
                    for (var i = 0; i < map.length - 1; i++) {
                        var current = map[i];
                        var next = map[i + 1];
                        // Current heading's content bottom is at or above viewport top
                        // (content has scrolled past)
                        if (current.contentBottom <= viewportHeight) {
                            // Check if next heading is coming into view
                            if (next.headingTop <= viewportHeight) {
                                return next.id;
                            }
                        }
                    }
                }
                // Scrolling UP: previous heading's content bottom appears at viewport top
                // -> switch to PREVIOUS heading
                else {
                    for (var i = 1; i < map.length; i++) {
                        var prev = map[i - 1];
                        var current = map[i];
                        // Current heading is at or near top
                        if (current.headingTop <= 50) {
                            // Previous heading's content bottom is at viewport top
                            // (content is becoming visible)
                            if (prev.contentBottom > 0 && prev.contentBottom <= viewportHeight) {
                                return prev.id;
                            }
                        }
                    }
                }

                // Fallback: find heading closest to viewport top
                var bestHeading = null;
                var bestDist = Infinity;
                for (var i = 0; i < map.length; i++) {
                    var item = map[i];
                    var dist = Math.abs(item.headingTop);
                    if (item.headingTop >= -100 && item.headingTop <= viewportHeight && dist < bestDist) {
                        bestDist = dist;
                        bestHeading = item.id;
                    }
                }

                return bestHeading;
            }

            function sendHeading() {
                if (!isInitialized) return;

                var heading = getVisibleHeading();
                if (heading !== lastSentHeading) {
                    lastSentHeading = heading;
                    window.webkit.messageHandlers.visibleHeading.postMessage(heading);
                }
            }

            // Throttled scroll handler
            var scrollTimeout = null;
            window.addEventListener('scroll', function() {
                if (scrollTimeout) clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(sendHeading, 30);
            }, {passive: true});

            // Initialize
            setTimeout(function() {
                isInitialized = true;
                lastScrollY = window.pageYOffset;
                sendHeading();
            }, 300);
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
                scrollToAnchor(anchor)
                pendingAnchor = nil
            }
        }

        func scrollToAnchor(_ anchor: String) {
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
            webView?.evaluateJavaScript(script) { [weak self] result, error in
                if let error = error {
                    print("Scroll error: \(error)")
                } else if let success = result as? Bool, !success {
                    print("Anchor not found: \(anchor)")
                } else {
                    // After scrolling to anchor, trigger visible heading update
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.webView?.evaluateJavaScript("window.scrollTo(window.pageXOffset, window.pageYOffset);") { _, _ in }
                    }
                }
            }
        }
    }
}
