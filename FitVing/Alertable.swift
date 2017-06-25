
import Foundation

protocol Alertable {
    func showErrorAlert(_ viewController: UIViewController)
    func showErrorAlert(_ viewController: UIViewController, title: String, message: String?)
}

extension Alertable {
    func showErrorAlert(_ viewController: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(_ viewController: UIViewController, title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
