
import UIKit
import Alamofire
import PKHUD

class TransferToBankViewController: UIViewController, Alertable {
    
    @IBOutlet weak fileprivate var estimatedArrivalLabel: UILabel!
    @IBOutlet weak fileprivate var profileImageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var amountLabel: UILabel!

    var amount: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "Transfer to Bank"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        
        let estimatedDate = Date().addingTimeInterval(60*60*24*3)
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        estimatedArrivalLabel.text = "Estimated Arrival : " + formatter.string(from: estimatedDate)
        
        if let amount = self.amount {
            amountLabel.text = ("$ " + amount).replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        }
        
        if let userId = FitVing.sharedInstance.facebookUserId {
            profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
        } else {
            profileImageView.image = UIImage(named: "ProfileImage")
        }
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2.0
        self.profileImageView.clipsToBounds = true
        
        if let username = FitVing.sharedInstance.facebookUsername {
            nameLabel.text = username
        } else {
            nameLabel.text = "Tortoise"
        }
    }
    
    fileprivate func sendMoney() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        guard let amount = self.amount else { return }
        
        let params = ["id":SPUserId, "amount":amount, "currency":"USD", "timezone":TimeZone.current.identifier]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/sendmoney", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            HUD.hide()
            if let JSON = response.result.value as? [String:Any] {
                if let result = JSON["result"] as? String {
                    if result == "success" {
                        self.notify()
                    }
                } else {
                    self.showErrorAlert(self)
                }
            } else {
                self.showErrorAlert(self)
            }
        }
    }
    
    fileprivate func notify() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "transferToBankRequested"), object: nil, userInfo: ["amount":self.amount as Any])
        self.performSegue(withIdentifier: "unwindToRootViewControllerSegue", sender: nil)
    }

    
    //MARK: - Actions
    
    @IBAction func transferPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Bank Transfer Initiated", message: "Your withdrawal could be delayed or blocked if we identify an issue. It doesn't happen often, but if it does we'll send you an email.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                print("OK")
            self.sendMoney()
        })
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
