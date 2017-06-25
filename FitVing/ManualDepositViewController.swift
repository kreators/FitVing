
import UIKit
import EventKit
import Alamofire
import PKHUD

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


protocol ManualDepositViewControllerDelegate {
    func depositAdded(_ deposit: Double)
}

class ManualDepositViewController: UIViewController, KeyPadViewControllerDelegate, PreFilledViewControllerDelegate, Alertable {
    
    @IBOutlet weak var keyPadButton: UIButton!
    @IBOutlet weak var preFilledButton: UIButton!
    @IBOutlet weak var keyPadView: UIView!
    @IBOutlet weak var preFilledView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var preFilledDescriptionLabel: UILabel!
    @IBOutlet weak var depositLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak fileprivate var turtleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var turtleViewWidthConstraint: NSLayoutConstraint!

    var delegate: ManualDepositViewControllerDelegate?
    var keyPadViewController: KeyPadViewController? = nil
    var depositAmount = 0.0
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCalendarAuthorizationStatus()
        
        if FitVing.sharedInstance.SPBankId == nil {
            performSegue(withIdentifier: "bankRegisterSegue", sender: nil)
        }
    }

    // MARK: - Helpers
    
    fileprivate func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            requestAccessToCalendar()
        case .authorized:
            print("OK")
        case .restricted, .denied:
            print("Denied")
        default:
            print("default")
        }
    }
    
    fileprivate func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                print("AccessGranted")
            } else {
                print("AccessDenied")
            }
        }
    }
    
    fileprivate func initUI() {
        FitVing.sharedInstance.flurryLogEvent("DepositActivity")

        keyPadButton.backgroundColor = UIColor.clear
        preFilledButton.backgroundColor = UIColor.defaultBlueColor()
        keyPadButton.isSelected = false
        preFilledButton.isSelected = true
        keyPadView.isHidden = true
        preFilledView.isHidden = false
        preFilledDescriptionLabel.text = ""
                depositLabel.text = ""
        self.depositAmount = 0.0
        keyPadButton.setImage(UIImage(named: "money_green"), for: .highlighted)
        keyPadButton.setImage(UIImage(named: "money"), for: [.highlighted , .selected] )
        preFilledButton.setImage(UIImage(named: "manual-deposit"), for: .highlighted)
        preFilledButton.setImage(UIImage(named: "manual-deposit_white"), for: [.highlighted , .selected] )
                depositLabelConstraint.constant = 20.0
        
        if UIScreen.main.bounds.width == 320.0 {
            self.turtleViewWidthConstraint.constant = 200.0
            self.turtleViewHeightConstraint.constant = 200.0
        }
        
        print(FitVing.sharedInstance.currencySymbol)
    }
    
    func insertEvent(_ amount: String, description: String) {
        amount.replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)

        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if status == EKAuthorizationStatus.authorized {
            let store = EKEventStore()
            let calendars = store.calendars(for: .event)
            let endDate = Date()
            let startDate = endDate.addingTimeInterval(-60*60)
            let event = EKEvent(eventStore: store)
            let desc = description.replacingOccurrences(of: "\n", with: "")
            event.calendar = store.defaultCalendarForNewEvents
            event.title = "Deposit \(amount) (\(desc)) to Tortoise Account"
            event.startDate = startDate
            event.endDate = endDate
            do {
                try store.save(event, span: .thisEvent)
            } catch {
                
            }
        }
    }
    
    func numberChanged(_ numberInput: String) {
        if numberInput == "" {
            depositLabel.text = "$ 0".replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
            self.depositAmount = 0.0
        }
        else {
            depositLabel.text = ("$ " + numberInput).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
            self.depositAmount = Double(numberInput)!
        }
    }
    
    func numberChanged(_ numberInput: String, description: String) {
        depositLabel.text = ("$ " + numberInput).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        self.depositAmount = Double(numberInput)!
        preFilledDescriptionLabel.text = description
    }
    
    fileprivate func receiveMoney() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        guard let amountLabel = self.depositLabel.text else { return }
        let index = amountLabel.index(amountLabel.startIndex, offsetBy: 2)
        let amount = amountLabel.substring(from: index)
        
        let params = ["id":SPUserId, "amount":amount, "currency":"USD", "timezone":TimeZone.current.identifier]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/receivemoney", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            HUD.hide()
            if let JSON = response.result.value as? [String:Any] {
                if let result = JSON["result"] as? String {
                    if result == "success" {
                        if let delegate = self.delegate {
                            delegate.depositAdded(self.depositAmount)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.showErrorAlert(self)
                }
            } else {
                self.showErrorAlert(self)
            }
        }
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
        depositLabel.text = "$ 0".replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        guard depositLabel.text?.characters.count > 0 else {
            return
        }
        if let _ = self.navigationController {
            self.performSegue(withIdentifier: "nextSegue", sender: nil)
        } else {
            self.receiveMoney()
        }
        if preFilledView.isHidden == false {
            let amount = "$\(self.depositAmount)"
            let description = preFilledDescriptionLabel.text
            insertEvent(amount, description: description!)
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
