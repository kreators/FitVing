
import UIKit
import Alamofire
import PKHUD
import GooglePlaces

class BasicInfoViewController: UIViewController, UITextFieldDelegate, Alertable, GMSAutocompleteTableDataSourceDelegate {
    
    @IBOutlet fileprivate weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var nextButton: UIButton! {
        didSet {
            nextButton.setBackgroundImage(UIImage.fromColor(color: .defaultBlueColor()), for: .normal)
            nextButton.isEnabled = false
        }
    }
    
    @IBOutlet fileprivate weak var firstNameTextField: UITextField!
    @IBOutlet fileprivate weak var lastNameTextField: UITextField!
    @IBOutlet fileprivate weak var phoneNumberTextField: UITextField!
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    @IBOutlet fileprivate weak var address1TextField: UITextField! {
        didSet {
            address1TextField.delegate = self
            address1TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet fileprivate weak var address2TextField: UITextField!
    @IBOutlet fileprivate weak var cityTextField: UITextField!
    @IBOutlet fileprivate weak var stateTextField: UITextField!
    @IBOutlet fileprivate weak var zipcodeTextField: UITextField!
    
    var resultsController: UITableViewController?
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    fileprivate var addressStreet: String?
    fileprivate var addressCity: String?
    fileprivate var addressSubdivision: String?
    fileprivate var addressPostalCode: String?
    fileprivate var dateOfBirth: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableDataSource = GMSAutocompleteTableDataSource()
        if let tableDataSource = self.tableDataSource {
            tableDataSource.delegate = self
        }
        self.resultsController = UITableViewController(style: .plain)
        if let resultsController = self.resultsController {
            resultsController.tableView.delegate = self.tableDataSource
            resultsController.tableView.dataSource = self.tableDataSource
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    
    fileprivate func createSPUser(email: String, phoneNumber: String, legalName: String, tortoiseUserId: String) {
        let params = ["email":email, "phoneNumber":phoneNumber, "legalName":legalName, "tortoiseUserId":tortoiseUserId]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/user", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let data = JSON["data"] as? [String:Any] {
                                if let SPUserId = data["SPUserId"] as? String {
                                    FitVing.sharedInstance.SPUserId = SPUserId
                                    self.addKYCInfo(email: email, phoneNumber: phoneNumber, legalName: legalName)
                                }
                            }
                        } else {
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }

    fileprivate func addKYCInfo(email: String, phoneNumber: String, legalName: String) {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        guard let addressStreet = self.addressStreet, let addressCity = self.addressCity, let addressSubdivision = self.addressSubdivision, let addressPostalCode = self.addressPostalCode else { return }
        guard let birthday = self.dateOfBirth?.components(separatedBy: "/") else { return }
        let year = birthday[0], month = birthday[1], day = birthday[2]
        
        let params = ["id":SPUserId, "email":email, "phoneNumber":phoneNumber, "name":legalName, "alias":"Tortoise User", "entityType":"NOT_KNOWN", "entityScope":"Not Known", "day":day, "month":month, "year":year, "addressStreet":addressStreet, "addressCity":addressCity, "addressSubdivision":addressSubdivision, "addressPostalCode":addressPostalCode, "addressCountryCode":"US"]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/addkycinfo", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            self.addTriumphSubAccountUS()
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }

    fileprivate func addTriumphSubAccountUS() {
        guard let SPUserId = FitVing.sharedInstance.SPUserId else { return }
        
        let params = ["id":SPUserId]
        HUD.show(.progress)
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/addtriumphsubaccountus", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                HUD.hide()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            self.performSegue(withIdentifier: "createAccountStep2Segue", sender: nil)
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }
    
    // MARK: - GMSAutocompleteTableDataSourceDelegate
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        guard let addressComponents = place.addressComponents else { return }
        self.address1TextField.resignFirstResponder()
        
        var streetNumber: String?, route: String?
        for component in addressComponents {
            if component.type == "street_number" {
                streetNumber = component.name
            } else if component.type == "route" {
                route = component.name
            } else if component.type == "locality" {
                self.addressCity = component.name
            } else if component.type == "administrative_area_level_1" {
                self.addressSubdivision = component.name
            } else if component.type == "postal_code" {
                self.addressPostalCode = component.name
            }
        }
        self.addressStreet = streetNumber ?? ""
        if let route = route {
            self.addressStreet! += " \(route)"
        }
        address1TextField.text = self.addressStreet
        cityTextField.text = self.addressCity
        stateTextField.text = self.addressSubdivision
        zipcodeTextField.text = self.addressPostalCode
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        self.address1TextField.resignFirstResponder()
        self.address1TextField.text = ""
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        HUD.show(.progress)
        if let resultsController = self.resultsController {
            resultsController.tableView.reloadData()
        }
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        if let resultsController = self.resultsController {
            resultsController.tableView.reloadData()
        }
        HUD.hide()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let resultsController = self.resultsController else { return }
        self.addChildViewController(resultsController)
        resultsController.view.translatesAutoresizingMaskIntoConstraints = false
        resultsController.view.alpha = 0.0
        self.view.addSubview(resultsController.view)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[address1TextField]-[resultView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["address1TextField":address1TextField, "resultView":resultsController.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[resultView]-(0)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["resultView":resultsController.view]))
        self.view.layoutIfNeeded()
        
        resultsController.tableView.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: { 
            resultsController.view.alpha = 1.0
        }) { (finished) in
            resultsController.didMove(toParentViewController: self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let resultsController = self.resultsController else { return }
        resultsController.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.5, animations: { 
            resultsController.view.alpha = 0.0
        }) { (finished) in
            resultsController.view.removeFromSuperview()
            resultsController.removeFromParentViewController()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if let tableDataSource = self.tableDataSource {
            tableDataSource.sourceTextHasChanged(textField.text)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func nextPressed(sender: UIButton) {
        guard let tortoiseUserId = FitVing.sharedInstance.tortoiseUserId else { return }
        guard let email = FitVing.sharedInstance.tortoiseUserEmail else { return }
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phoneNumber = phoneNumberTextField.text, let date = dateTextField.text, let address1 = address1TextField.text, let city = cityTextField.text, let state = stateTextField.text, let zipcode = zipcodeTextField.text else {
            showErrorAlert(self, title: "Required field is empty.", message: nil)
            return
        }
        guard firstName.characters.count > 0 && lastName.characters.count > 0 && phoneNumber.characters.count > 0 && date.characters.count > 0, address1.characters.count > 0 && city.characters.count > 0 && state.characters.count > 0 && zipcode.characters.count > 0 else {
            showErrorAlert(self, title: "Required field is empty.", message: nil)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/mm/dd"
        guard dateFormatter.date(from: date) != nil else {
            showErrorAlert(self, title: "Date is invalid.", message: nil)
            return
        }
        
        if let address2 = address2TextField.text {
            self.addressStreet! += " \(address2)"
        }
        let name = "\(firstName) \(lastName)"
        self.dateOfBirth = date
        createSPUser(email: email, phoneNumber: phoneNumber, legalName: name, tortoiseUserId: tortoiseUserId)
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
            self.containerViewBottomConstraint.constant = 0.0
        } else {
            self.containerViewBottomConstraint.constant = endFrame.size.height
        }
        UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: { self.view.layoutIfNeeded() }, completion: nil)
        self.nextButton.isEnabled = true
    }
}
