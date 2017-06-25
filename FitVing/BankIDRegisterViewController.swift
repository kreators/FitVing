
import UIKit
import Alamofire
import PKHUD

class BankIDRegisterViewController: UIViewController, Alertable {
    
    @IBOutlet fileprivate weak var submitButton: UIButton! {
        didSet {
            submitButton.isHidden = true
        }
    }
    @IBOutlet fileprivate weak var idTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!

    var bankCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        idTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func addACHUSLogins() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        guard let bankCode = self.bankCode else { return }
        guard let bankId = idTextField.text else { return }
        guard let bankPassword = passwordTextField.text else { return }
        
/* */        let params = ["id":SPUserId, "bankId":"synapse_nomfa", "bankPassword":"test1234", "bankName":"fake"] /* */
//        let params = ["id":SPUserId, "bankId":bankId, "bankPassword":bankPassword, "bankName":bankCode]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/addachuslogins", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            HUD.hide()
            if let JSON = response.result.value as? [String:Any] {
                if let result = JSON["result"] as? String {
                    if result == "success" {
                        if let data = JSON["data"] as? [[String:Any]] {
                            if let first = data.first {
                                if let mfa = first["mfa"] as? [String:String?] {
                                    if let type = mfa["type"] as? String, let message = mfa["message"] as? String, let accessToken = mfa["access_token"] as? String {
                                        let alertController = UIAlertController(title: type, message: message, preferredStyle: .alert)
                                        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alertController] _ in
                                            if let alertController = alertController {
                                                let answerTextField = alertController.textFields![0] as UITextField
                                                if let mfaAnswer = answerTextField.text {
                                                    self.requestACHUSMFA(accessToken: accessToken, mfaAnswer: mfaAnswer)
                                                }
                                            }
                                        }
                                        submitAction.isEnabled = false
                                        
                                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                                        
                                        alertController.addTextField(configurationHandler: { (textField) in
                                            textField.placeholder = "Type answer"
                                            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                                                submitAction.isEnabled = textField.text != ""
                                            }
                                        })
                                        alertController.addAction(submitAction)
                                        alertController.addAction(cancelAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        
                                    } else {
                                        self.showErrorAlert(self)
                                    }
                                } else {
                                    FitVing.sharedInstance.SPBankId = "BankId"
                                    self.performSegue(withIdentifier: "bankAccountSegue", sender: data)
                                }
                            }
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                } else {
                    self.showErrorAlert(self)
                }
            }
            else {
                self.showErrorAlert(self)
            }
        }
    }
    
    fileprivate func requestACHUSMFA(accessToken: String, mfaAnswer: String) {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        
        let params = ["id":SPUserId, "access_token":accessToken, "mfa_answer":mfaAnswer]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/achusmfa", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let data = JSON["data"] as? [[String:Any]] {
                                if let first = data.first {
                                    if let mfa = first["mfa"] as? [String:String?] {
                                        if let type = mfa["type"] as? String, let message = mfa["message"] as? String, let accessToken = mfa["access_token"] as? String {
                                            let alertController = UIAlertController(title: type, message: message, preferredStyle: .alert)
                                            let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alertController] _ in
                                                if let alertController = alertController {
                                                    let answerTextField = alertController.textFields![0] as UITextField
                                                    if let mfaAnswer = answerTextField.text {
                                                        self.requestACHUSMFA(accessToken: accessToken, mfaAnswer: mfaAnswer)
                                                    }
                                                }
                                            }
                                            submitAction.isEnabled = false
                                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                                            alertController.addTextField(configurationHandler: { (textField) in
                                                textField.placeholder = "Type answer"
                                                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                                                    submitAction.isEnabled = textField.text != ""
                                                }
                                            })
                                            alertController.addAction(submitAction)
                                            alertController.addAction(cancelAction)
                                            self.present(alertController, animated: true, completion: nil)
                                            
                                        } else {
                                            self.showErrorAlert(self)
                                        }
                                    } else {
                                        FitVing.sharedInstance.SPBankId = "BankId"
                                        self.performSegue(withIdentifier: "bankAccountSegue", sender: data)
                                    }
                                }
                            }
                        } else {
                            self.showErrorAlert(self)
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        guard let idCount = idTextField.text?.characters.count else { return }
        guard let passwordCount = passwordTextField.text?.characters.count else { return }
        submitButton.isHidden = idCount == 0 || passwordCount == 0
    }
    
    // MARK: - Actions
    
    @IBAction func submitPressed(sender: UIButton) {
        if idTextField.isFirstResponder {
            idTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        addACHUSLogins()
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankAccountSegue" {
            let vc = segue.destination as! BankAccountViewController
            if let accounts = sender as? [[String:Any]] {
                vc.bankAccounts = accounts
            }
        }
    }
}
