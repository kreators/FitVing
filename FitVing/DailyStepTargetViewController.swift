
import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class DailyStepTargetViewController: UIViewController, KeyPadViewControllerDelegate, PreFilledViewControllerDelegate {
    
    @IBOutlet fileprivate weak var nextButton: UIButton! {
        didSet {
            nextButton.setBackgroundImage(UIImage.fromColor(color: .defaultBlueColor()), for: .normal)
            nextButton.isEnabled = false
        }
    }
    @IBOutlet weak var keyPadView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak fileprivate var interestLabel: UILabel!
    
    var fromSettings = false
    var keyPadViewController: KeyPadViewController? = nil
    var stepTarget = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        if fromSettings {
            self.navigationController?.navigationBar.isHidden = true
        }
        keyPadView.isHidden = false
        depositLabel.text = "0"
        self.stepTarget = 0
        
        let interestString = String(0.0)
        let attributeText = NSMutableAttributedString(string: "(estimated interest rate \(interestString)%)")
        attributeText.addAttributes([NSForegroundColorAttributeName:UIColor.defaultYellowColor()], range: NSMakeRange(25, interestString.characters.count))
        interestLabel.attributedText = attributeText
    }
    
    func numberChanged(_ numberInput: String) {
        if numberInput == "" {
            depositLabel.text = "0"
            self.stepTarget = 0
        }
        else {
            self.stepTarget = Int(numberInput)!
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            depositLabel.text = numberFormatter.string(from: NSNumber(integerLiteral: self.stepTarget))
        }
        var interest = 0.0
        if self.stepTarget < 1000 {
            interest = 0.002
        } else if self.stepTarget < 2000 {
            interest = 0.01
        } else if self.stepTarget < 3000 {
            interest = 0.021
        } else if self.stepTarget < 4000 {
            interest = 0.104
        } else if self.stepTarget < 5000 {
            interest = 0.208
        } else if self.stepTarget < 6000 {
            interest = 0.39
        } else if self.stepTarget < 7000 {
            interest = 0.667
        } else if self.stepTarget < 8000 {
            interest = 1.067
        } else if self.stepTarget < 9000 {
            interest = 1.502
        } else if self.stepTarget < 10000 {
            interest = 1.956
        } else {
            interest = 2.5
        }
        let interestString = String(interest)
        let attributeText = NSMutableAttributedString(string: "(estimated interest rate \(interestString)%)")
        attributeText.addAttributes([NSForegroundColorAttributeName:UIColor.defaultYellowColor()], range: NSMakeRange(25, interestString.characters.count))
        interestLabel.attributedText = attributeText
        
        if self.stepTarget == 0 {
            self.nextButton.isEnabled = false
        } else {
            self.nextButton.isEnabled = true
        }
    }
    
    func numberChanged(_ numberInput: String, description: String) {
        depositLabel.text = numberInput
        self.stepTarget = Int(numberInput)!
    }
    
    // MARK: - Actions
    
    @IBAction func nextPressed(sender: UIButton) {
        guard self.stepTarget > 0 else { return }
        FitVing.sharedInstance.addTargetSteps(self.stepTarget, date: Date.Now())
        performSegue(withIdentifier: "dailyDepositSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "keyPadEmbed" {
            if let vc = segue.destination as? KeyPadViewController {
                self.keyPadViewController = vc
                vc.delegate = self
                vc.stepsMode = true
            }
        }
    }
}
