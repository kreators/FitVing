
import UIKit
import Alamofire
import PKHUD

class BankAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable {
    
    @IBOutlet fileprivate weak var submitButton: UIButton! {
        didSet {
            submitButton.isHidden = true
        }
    }

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var bankAccounts: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func selectBankAccount() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        guard let rowSelected = self.tableView.indexPathForSelectedRow else { return }
        guard let bankAccounts = self.bankAccounts else { return }
        let accountSelected = bankAccounts[rowSelected.row]
        guard let nodeIdSelected = accountSelected["_id"] as? String else { return }
        var nodeIdDiscard = [String]()
        for bankAccount in bankAccounts {
            if let nodeId = bankAccount["_id"] as? String {
                if nodeId != nodeIdSelected {
                    nodeIdDiscard.append(nodeId)
                }
            }
        }
        let params: [String : Any] = ["id":SPUserId, "nodeIdSelected":nodeIdSelected, "nodeIdDiscard":nodeIdDiscard]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/selectbankaccount", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            HUD.hide()
            if let JSON = response.result.value as? [String:Any] {
                if let result = JSON["result"] as? String {
                    if result == "success" {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showErrorAlert(self)
                    }
                } else {
                    self.showErrorAlert(self)
                }
            }
        }
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let bankAccounts = self.bankAccounts else { return 0 }
        return bankAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath)
        guard let bankAccounts = self.bankAccounts else { return cell }
        let account = bankAccounts[indexPath.row]
            if let info = account["info"] as? [String:Any] {
                if let accountNumber = info["account_num"] as? String, let accountClass = info["class"] as? String {
                    cell.textLabel?.text = accountNumber
                    cell.detailTextLabel?.text = accountClass
                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.submitButton.isHidden = false
    }

    // MARK: - Actions
    
    @IBAction func submitPressed(sender: UIButton) {
        selectBankAccount()
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
