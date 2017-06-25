
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


protocol DepositViewControllerDelegate {
    func depositChanged(_ deposit: Double)
}

class DepositViewController: UIViewController, KeyPadViewControllerDelegate, PreFilledViewControllerDelegate {
    
    @IBOutlet weak var keyPadButton: UIButton!
    @IBOutlet weak var preFilledButton: UIButton!
    @IBOutlet weak var keyPadView: UIView!
    @IBOutlet weak var preFilledView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var preFilledDescriptionLabel: UILabel!
    @IBOutlet weak var depositLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var submitButton: UIButton!
    
    var delegate: DepositViewControllerDelegate?
    var keyPadViewController: KeyPadViewController? = nil
    var depositAmount = 0.0
    var fromSettings = false
    
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
        

        self.submitButton.isHidden = true
        
        keyPadButton.backgroundColor = UIColor.defaultBlueColor()
        preFilledButton.backgroundColor = UIColor.clear
        keyPadButton.isSelected = true
        preFilledButton.isSelected = false
        keyPadView.isHidden = false
        preFilledView.isHidden = true
        preFilledDescriptionLabel.text = ""
        depositLabel.text = "$ 0"
        self.depositAmount = 0.0
        keyPadButton.setImage(UIImage(named: "money_green"), for: .highlighted)
        keyPadButton.setImage(UIImage(named: "money"), for: [.highlighted , .selected] )
        preFilledButton.setImage(UIImage(named: "manual-deposit"), for: .highlighted)
        preFilledButton.setImage(UIImage(named: "manual-deposit_white"), for: [.highlighted , .selected] )
    }
    
    func numberChanged(_ numberInput: String) {
        if numberInput == "" {
            depositLabel.text = "$ 0"
            self.depositAmount = 0.0
        }
        else {
            depositLabel.text = "$ " + numberInput
            self.depositAmount = Double(numberInput)!
        }
        self.submitButton.isHidden = self.depositAmount == 0.0 ? true : false
    }
    
    func numberChanged(_ numberInput: String, description: String) {
        depositLabel.text = "$ " + numberInput
        self.depositAmount = Double(numberInput)!
        preFilledDescriptionLabel.text = description
    }
    
    // MARK: - Actions
    
    @IBAction func keyPadPressed(_ sender: UIButton) {
        FitVing.sharedInstance.flurryLogEvent("DepositDollar")
        keyPadButton.backgroundColor = UIColor.defaultBlueColor()
        preFilledButton.backgroundColor = UIColor.clear
        keyPadButton.isSelected = true
        preFilledButton.isSelected = false
        keyPadView.isHidden = false
        preFilledView.isHidden = true
        preFilledDescriptionLabel.text = ""
        depositLabel.text = "$ 0"
        self.depositAmount = 0.0
        if let keyPadViewController = self.keyPadViewController {
            keyPadViewController.numberInput = ""
        }
        depositLabelConstraint.constant = 0.0
    }
    
    @IBAction func preFilledPressed(_ sender: UIButton) {
        FitVing.sharedInstance.flurryLogEvent("DepositActivity")
        keyPadButton.backgroundColor = UIColor.clear
        preFilledButton.backgroundColor = UIColor.defaultBlueColor()
        keyPadButton.isSelected = false
        preFilledButton.isSelected = true
        keyPadView.isHidden = true
        preFilledView.isHidden = false
        depositLabel.text = ""
        self.depositAmount = 0.0
        depositLabelConstraint.constant = 20.0
    }
    
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
            delegate.depositChanged(self.depositAmount)
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
            }
        } else if segue.identifier == "preFilledEmbed" {
            let vc = segue.destination as! PreFilledViewController
            vc.delegate = self
        }
    }
}
