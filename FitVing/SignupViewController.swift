
import UIKit
import Alamofire
import PKHUD

class SignupViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet fileprivate weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var fbLoginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Helpers
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func MD5(_ string: String) -> String? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex = digestData.map { String(format: "%02hhx", $0) }.joined()
        return md5Hex
    }
    
    fileprivate func signupRequest(params: [String:String]) {
        guard let emailString = params["emailId"] else { return }
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/tortoiseuser", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let data = JSON["data"] as? [String:Any] {
                                if let tortoiseUserId = data["TortoiseUserId"] as? String {
                                    FitVing.sharedInstance.tortoiseUserId = tortoiseUserId
                                    FitVing.sharedInstance.tortoiseUserEmail = emailString
                                }
                            }
                            self.performSegue(withIdentifier: "agreementSegue", sender: nil)
                        } else {
                            if let data = JSON["data"] as? String {
                                if data == "duplicated" {
                                    let alertController = UIAlertController(title: "Email is already used", message: nil, preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion: nil)
                                } else if data == "duplicated facebookId" {
                                    FBSDKLoginManager().logOut()
                                    let alertController = UIAlertController(title: "Facebook Id is already used", message: nil, preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    } else {
                        let alertController = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func singupPressed(sender: UIButton) {
        guard let emailString = self.emailTextField.text else { return }
        guard let password = self.passwordTextField.text else { return }
        guard isValidEmail(testStr: emailString) else {
            let alertController = UIAlertController(title: "Invalid Email", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard password.characters.count > 5 else {
            let alertController = UIAlertController(title: "Password length > 5", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard let md5Hex = MD5(password) else { return }
        
        let params = ["emailId":emailString, "emailPassword":md5Hex, "facebookId":"facebookId", "type":"email"]
        signupRequest(params: params)
    }
    
    @IBAction func haveAccountPressed(sender: UIButton) {
        performSegue(withIdentifier: "haveAccountSegue", sender: self)
    }
    
    func signupWithFacebookPressed() {
        
    }
    
    // MARK: - FBSDK
    
    func returnUserData()
    {
        let params = ["fields":"id,email,name"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Facebook Error")
            }
            else {
                guard let graphResult = result as? [String:String] else { return }
                guard let facebookId = graphResult["id"] else { return }
                FitVing.sharedInstance.facebookUserId = facebookId
                guard let userName = graphResult["name"] else { return }
                FitVing.sharedInstance.facebookUsername = userName
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ProfileImageUpdated"), object: nil)
                if let emailString = graphResult["email"] {
                    let params = ["emailId":emailString, "emailPassword":"md5Hex", "facebookId":facebookId, "facebookUsername":userName, "type":"facebook"]
                    self.signupRequest(params: params)
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Email is required", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
        } else if result.isCancelled {
        } else {
            if result.grantedPermissions.contains("email") {
            }
            returnUserData()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }

    // MARK: - Keyboard Notification
    
    func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            self.containerViewTopConstraint.constant = 0.0
            self.containerViewBottomConstraint.constant = 0.0
        } else {
            let delta = CGFloat(300 - 144) //self.containerViewBottomConstraint.constant
            self.containerViewTopConstraint.constant = -delta
            self.containerViewBottomConstraint.constant = 300.0
        }
        UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}
