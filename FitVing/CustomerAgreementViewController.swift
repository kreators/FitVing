
import UIKit

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

class CustomerAgreementViewController: UIViewController {
    
    @IBOutlet fileprivate weak var agreeButton: UIButton! {
        didSet {
            agreeButton.setBackgroundImage(UIImage.fromColor(color: .defaultBlueColor()), for: .normal)
            agreeButton.isEnabled = false
        }
    }
    @IBOutlet fileprivate weak var disagreeButton: UIButton! {
        didSet {
            disagreeButton.layer.borderColor = UIColor.defaultBlueColor().cgColor
            disagreeButton.layer.borderWidth = 1.0
        }
    }
    @IBOutlet fileprivate weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdf = Bundle.main.url(forResource: "ONLINETERMSOFUSE", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func checkbox(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agreeButton.isEnabled = sender.isSelected
    }
    
    @IBAction func agreePressed(sender: UIButton) {
        performSegue(withIdentifier: "createAccountStep1Segue", sender: nil)
    }
}
