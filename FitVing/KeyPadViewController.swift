
import UIKit

protocol KeyPadViewControllerDelegate {
    func numberChanged(_ numberInput: String)
}

class KeyPadViewController: UIViewController {
    
    var numberInput = ""
    var delegate: KeyPadViewControllerDelegate?
    var stepsMode = false
    
    @IBOutlet weak var dotButton: UIButton! {
        didSet {
            if FitVing.sharedInstance.currencySymbol != "$" {
                dotButton.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if numberInput == "" {
            if sender.tag == 0 {
                return
            }
        }
        if stepsMode == false {
            if numberInput.characters.count >= 4 {
                return
            }
        }
        numberInput += String(sender.tag)
        if let delegate = self.delegate {
            delegate.numberChanged(numberInput)
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        if numberInput == "" {
        }
        else {
            numberInput.remove(at: numberInput.characters.index(numberInput.endIndex, offsetBy: -1))
            if let delegate = self.delegate {
                delegate.numberChanged(numberInput)
            }
        }
    }
    
    @IBAction func dotPressed(_ sender: UIButton) {
        if stepsMode == false {
            if numberInput.characters.count >= 4 {
                return
            }
        } else {
            return
        }
        
        if numberInput.characters.contains(".") {
            return
        }

        if numberInput == "" {
            numberInput += "0."
        }
        else {
            numberInput += "."
        }
        if let delegate = self.delegate {
            delegate.numberChanged(numberInput)
        }
    }
}
