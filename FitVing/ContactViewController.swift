
import UIKit
import WebKit
import PKHUD

class ContactViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet fileprivate weak var containerView: UIView!
    
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = self.containerView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HUD.flash(.progress, delay: 60)
        webView.load(URLRequest(url: URL(string: "https://www.newtortoise.com/contact-us")!))
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "Contact"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        
        self.webView.navigationDelegate = self
        self.containerView.addSubview(webView)
    }
    
    // MARK: - WebViewDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HUD.hide()
    }
}
