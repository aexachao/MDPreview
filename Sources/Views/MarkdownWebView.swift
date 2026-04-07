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
        context.coordinator.pendingAnchor = scrollToAnchor
        context.coordinator.onVisibleHeadingChange = onVisibleHeadingChange
        webView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private var scrollObserverScript: String {
        """
        (function() {
            var visibleHeading = null;

            function getVisibleHeading() {
                var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
                if (headings.length === 0) return null;

                var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                var viewportHeight = window.innerHeight;
                var bestHeading = null;
                var bestDistance = Infinity;

                for (var i = 0; i < headings.length; i++) {
                    var heading = headings[i];
                    var rect = heading.getBoundingClientRect();

                    if (!heading.id) continue;

                    if (rect.top >= 0 && rect.top < viewportHeight * 0.6) {
                        var distance = Math.abs(rect.top);
                        if (distance < bestDistance) {
                            bestDistance = distance;
                            bestHeading = heading.id;
                        }
                    }
                }

                if (!bestHeading) {
                    for (var i = 0; i < headings.length; i++) {
                        var heading = headings[i];
                        if (!heading.id) continue;
                        if (heading.getBoundingClientRect().top < 0) {
                            bestHeading = heading.id;
                            break;
                        }
                    }
                }

                return bestHeading;
            }

            function sendVisibleHeading() {
                var current = getVisibleHeading();
                if (current !== visibleHeading) {
                    visibleHeading = current;
                    window.webkit.messageHandlers.visibleHeading.postMessage(current);
                }
            }

            var timeout = null;
            window.addEventListener('scroll', function() {
                if (timeout) clearTimeout(timeout);
                timeout = setTimeout(sendVisibleHeading, 50);
            }, {passive: true});

            setTimeout(sendVisibleHeading, 200);
        })();
        """
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MarkdownWebView
        weak var webView: WKWebView?
        var pendingAnchor: String?
        var onVisibleHeadingChange: ((String?) -> Void)?
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
