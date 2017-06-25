
import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    fileprivate let screenWidth = UIScreen.main.bounds.width
    fileprivate let screenHeight = UIScreen.main.bounds.height
    fileprivate var loginNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helpers
    
    fileprivate func initUI() {
        let introImages = ["Onboarding1", "Onboarding2", "Onboarding3", "Onboarding4"]
        for i in 0 ... 3 {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * screenWidth, y: 0.0, width: screenWidth, height: screenHeight))
            imageView.image = UIImage(named: introImages[i])
            self.scrollView.addSubview(imageView)
            if i == 3 {
                let nextButton = UIButton(frame: CGRect(x: 0.0, y: screenHeight - 55.0, width: screenWidth, height: 55.0))
                nextButton.backgroundColor = UIColor.clear
                nextButton.addTarget(self, action: #selector(nextPressed(sender:)), for: .touchUpInside)
                imageView.addSubview(nextButton)
                imageView.isUserInteractionEnabled = true
            }
        }
        self.scrollView.contentSize = CGSize(width: screenWidth * 4, height: screenHeight)
        self.scrollView.isPagingEnabled = true
    }

    // MARK: - Actions
    
    func nextPressed(sender: UIButton) {
        performSegue(withIdentifier: "signupSegue", sender: nil)
    }
}
