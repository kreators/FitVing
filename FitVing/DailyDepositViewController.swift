
import UIKit
import EventKit

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


class DailyDepositViewController: UIViewController, KeyPadViewControllerDelegate {
    
    @IBOutlet fileprivate weak var depositButton: UIButton! {
        didSet {
            depositButton.setBackgroundImage(UIImage.fromColor(color: .defaultBlueColor()), for: .normal)
            depositButton.isEnabled = false
        }
    }
    @IBOutlet fileprivate weak var skipButton: UIButton! {
        didSet {
            skipButton.layer.borderColor = UIColor.defaultBlueColor().cgColor
            skipButton.layer.borderWidth = 1.0
        }
    }
    @IBOutlet fileprivate weak var turtleView: ManualDepositTurtleView! {
        didSet {
            turtleView.isHidden = true
        }
    }
    
    @IBOutlet fileprivate weak var infoButton: UIButton!
    @IBOutlet weak var keyPadView: UIView!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var exampleLable: UILabel!
    
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
        keyPadView.isHidden = false
        depositLabel.text = ""
        self.depositAmount = 0.0
        
        if UIScreen.main.bounds.width == 320.0 {
            self.turtleViewWidthConstraint.constant = 200.0
            self.turtleViewHeightConstraint.constant = 200.0
        }
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
        if self.turtleView.isHidden {
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            self.exampleLable.isHidden = true
            self.infoButton.isHidden = true
            self.turtleView.isHidden = false
        }
        if numberInput == "" {
            depositLabel.text = "$ 0".replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
            self.depositAmount = 0.0
        }
        else {
            depositLabel.text = ("$ " + numberInput).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
            self.depositAmount = Double(numberInput)!
        }
        
        self.depositButton.isEnabled = self.depositAmount > 0
    }

    // MARK: - Actions
    
    @IBAction func infoPressed(sender: UIButton) {
        performSegue(withIdentifier: "dailyDepositInfoSegue", sender: nil)
    }
    
    @IBAction func skipPressed(sender: UIButton) {
        performSegue(withIdentifier: "createAccountStep3Segue", sender: nil)
    }
    
    @IBAction func depositPressed(sender: UIButton) {
        FitVing.sharedInstance.addTargetDeposit(self.depositAmount, date: Date.Now())
        FitVing.sharedInstance.signupCompleted()
        performSegue(withIdentifier: "createAccountStep3Segue", sender: nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "keyPadEmbed" {
            if let vc = segue.destination as? KeyPadViewController {
                self.keyPadViewController = vc
                vc.delegate = self
            }
        }
    }
}

