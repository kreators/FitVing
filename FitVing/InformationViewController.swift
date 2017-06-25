
import UIKit

class InformationViewController: UIViewController {

    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var calculatedInterestAmountLabel: UILabel!
    @IBOutlet weak var calculatedPrincipalAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        let information = "Total balance is sum of principal and interest, based on the daily step goal and deposit."
        let fontSize: CGFloat = UIScreen.main.bounds.width == 320.0 ? 16.0 : 20.0
        let font = UIFont(name: "HelveticaNeue", size: fontSize)!
        
        let attributeText = NSMutableAttributedString(string: information)
        attributeText.addAttributes([NSFontAttributeName:font, NSForegroundColorAttributeName:UIColor.white], range: NSMakeRange(0, information.characters.count))

        attributeText.addAttributes([NSForegroundColorAttributeName:UIColor.defaultYellowColor()], range: NSMakeRange(17, 29))

        self.informationLabel.attributedText = attributeText
        
        let currentPrincipal = FitVing.sharedInstance.currentPrincipal
        let currentInterest = FitVing.sharedInstance.currentBalance - FitVing.sharedInstance.currentPrincipal
        
        self.calculatedPrincipalAmountLabel.text = String(format: "$ %.9f", currentPrincipal).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        self.calculatedInterestAmountLabel.text = String(format: "$ %.9f", currentInterest).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
    }
}
