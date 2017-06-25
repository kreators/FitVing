
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


protocol StepTargetViewControllerDelegate {
    func stepTargetChanged(_ stepTarget: Int)
}

class StepTargetViewController: UIViewController, KeyPadViewControllerDelegate, PreFilledViewControllerDelegate {
    
    @IBOutlet weak var keyPadView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak fileprivate var interestLabel: UILabel!
    @IBOutlet weak fileprivate var submitButton: UIButton!
    
    var fromSettings = false
    var delegate: StepTargetViewControllerDelegate?
    var keyPadViewController: KeyPadViewController? = nil
    var stepTarget = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        if let homeViewController = FitVing.sharedInstance.homeViewController {
            self.delegate = homeViewController
        }
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
        self.submitButton.isHidden = true
        
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
            depositLabel.text = numberInput
            self.stepTarget = Int(numberInput)!
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
            self.submitButton.isHidden = true
        } else {
            self.submitButton.isHidden = false
        }

    }
    
    func numberChanged(_ numberInput: String, description: String) {
        depositLabel.text = numberInput
        self.stepTarget = Int(numberInput)!
    }
    
    // MARK: - Actions
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        if fromSettings {
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        guard depositLabel.text?.characters.count > 0 else {
            return
        }
        if let delegate = self.delegate {
            delegate.stepTargetChanged(self.stepTarget)
        }
        if fromSettings {
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.navigationBar.isHidden = false
        } else {
            self.performSegue(withIdentifier: "nextSegue", sender: nil)
        }
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
