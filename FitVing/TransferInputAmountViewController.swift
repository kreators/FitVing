
import UIKit
import Alamofire
import PKHUD

class TransferInputAmountViewController: UIViewController, KeyPadViewControllerDelegate, Alertable {
    
    @IBOutlet weak fileprivate var amountLabel: UILabel!
    @IBOutlet weak fileprivate var turtleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var turtleViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var availableAmountLabel: UILabel!
    
    var amountInput: String?
    var availableAmount: Float = 0.0
    var availableCurrency = "USD"

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAccountBalance()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "Amount To Transfer"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        
        let depositButton = UIButton(type: .custom)
        depositButton.frame = CGRect(x: 0.0, y: 0.0, width: 21.0, height: 26.0)
        depositButton.setImage(UIImage(named: "deposit"), for: UIControlState())
        depositButton.addTarget(self, action: #selector(self.nextPressed(sender:)), for: .touchUpInside)
        
        let rightBarButtonItem = UIBarButtonItem(customView: depositButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        if UIScreen.main.bounds.width == 320.0 {
            self.turtleViewWidthConstraint.constant = 200.0
            self.turtleViewHeightConstraint.constant = 200.0
        }
        amountLabel.text = "$ 0".replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
    }
    
    fileprivate func requestAccountBalance() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        let params = ["id":SPUserId]
        
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/triumphinformation", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let data = JSON["data"] as? [String:Any] {
                                if let info = data["info"] as? [String:Any] {
                                    if let balance = info["balance"] as? [String:Any] {
                                        if let amount = balance["amount"] as? String, let currency = balance["currency"] as? String {
                                            self.availableAmount = Float(amount) ?? 0.0
                                            self.availableCurrency = currency
                                            self.updateAvailableAmountLabel()
                                        } else if let amount = balance["amount"] as? Float, let currency = balance["currency"] as? String {
                                            self.availableAmount = amount
                                            self.availableCurrency = currency
                                            self.updateAvailableAmountLabel()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }

    fileprivate func updateAvailableAmountLabel() {
        self.availableAmountLabel.text = "Balance : \(self.availableAmount) \(self.availableCurrency)"
    }
    
    //MARK: - Actions
    
    func nextPressed(sender: UIButton) {
        guard let amountInput = self.amountInput, let amount = Float(amountInput) else { return }
        if amount <= self.availableAmount && amount > 0.0 {
            performSegue(withIdentifier: "transferToBankSegue", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Check your balance.", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - KeyPadViewControllerDelegate
    
    
    func numberChanged(_ numberInput: String) {
        if numberInput == "" {
            amountLabel.text = "$ 0".replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        }
        else {
            amountLabel.text = ("$ " + numberInput).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        }
        self.amountInput = numberInput
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "keyPadEmbed" {
            if let vc = segue.destination as? KeyPadViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "transferToBankSegue" {
            if let vc = segue.destination as? TransferToBankViewController {
                vc.amount = self.amountInput
            }
        }
    }
}
