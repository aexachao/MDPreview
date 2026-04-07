import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    var scrollToAnchor: String?

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Store the anchor to scroll to after page loads
        context.coordinator.pendingAnchor = scrollToAnchor
        webView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MarkdownWebView
        weak var webView: WKWebView?
        var pendingAnchor: String?

        init(_ parent: MarkdownWebView) {
            self.parent = parent
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
            // Page finished loading, now scroll to anchor if any
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
            webView?.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Scroll error: \(error)")
                } else if let success = result as? Bool, !success {
                    print("Anchor not found: \(anchor)")
                }
            }
        }
    }
}
