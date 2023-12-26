import SwiftUI
import WebKit


class HiddenWebViewLoader: NSObject, WKNavigationDelegate {
    
    static let shared = HiddenWebViewLoader()
    var webView: WKWebView!
    var completionHandler: ((String?) -> Void)?

    
    
    override init() {
        super.init()
        let webConfig = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true
        webConfig.defaultWebpagePreferences = preferences
        
        self.webView = WKWebView(frame: .zero, configuration: webConfig)
        self.webView.navigationDelegate = self

        self.webView?.loadHTMLString("<html><body><h1>Hello, world!</h1></body></html>", baseURL: nil)
        print("HiddenWebViewLoader initialized")
    }

    
    

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed with error: \(error)")
    }

    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started navigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigation")
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                               completionHandler: { (html: Any?, error: Error?) in
                                if let error = error {
                                    print("JavaScript evaluation failed: \(error)")
                                }
                                if let htmlString = html as? String {
                                    print("Successfully fetched HTML")
                                    self.completionHandler?(htmlString)
                                } else {
                                    print("Failed to fetch HTML")
                                    self.completionHandler?(nil)
                                }
                               })
    }
    
    
    func loadContentForCity(city: String, plateNumber: String, completion: @escaping (String?) -> Void) {
        self.completionHandler = completion
        DispatchQueue.main.async { [weak self] in
            if let url = URL(string: "https://www.eczaneler.gen.tr/iframe.php?lokasyon=\(plateNumber)") {
                let request = URLRequest(url: url)
                self?.webView?.load(request)
            }
        }
    }
    
}
