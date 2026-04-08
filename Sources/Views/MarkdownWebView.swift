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
            console.log('[ScrollObserver] Script initializing...');

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
                var bestHeading = null;
                var bestTop = Infinity;

                for (var i = 0; i < headings.length; i++) {
                    var heading = headings[i];
                    if (!heading.id) continue;

                    var rect = heading.getBoundingClientRect();
                    // Heading is in or near viewport
                    if (rect.top >= -200 && rect.top <= viewportHeight) {
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
                console.log('[ScrollObserver] sendHeading:', heading, 'lastSent:', lastSentHeading);
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
                console.log('[ScrollObserver] scrollY:', scrollY, 'down:', isScrollingDown, 'heading:', heading);
                sendHeading(heading);
            }

            // Throttled scroll handler
            var scrollTimeout = null;
            window.addEventListener('scroll', function() {
                if (scrollTimeout) clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(onScroll, 50);
            }, {passive: true});

            // Initialize
            setTimeout(function() {
                console.log('[ScrollObserver] Initializing...');
                isInitialized = true;
                lastScrollY = window.pageYOffset;
                var heading = getHeadingAtTop();
                console.log('[ScrollObserver] Initial heading:', heading);
                sendHeading(heading);
            }, 500);

            console.log('[ScrollObserver] Script loaded');
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
