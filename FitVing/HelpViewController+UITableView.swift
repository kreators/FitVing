
import Foundation
import UIKit
import MessageUI

extension HelpViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath)
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.textLabel!.text = NSLocalizedString("About Tortoise", comment: "About Tortoise")
        case 1:
            cell.textLabel!.text = NSLocalizedString("Contact", comment: "Contact")
        case 2:
            cell.textLabel!.text = NSLocalizedString("Send Feedback", comment: "Send Feedback")
        case 3:
            cell.textLabel!.text = NSLocalizedString("User Agreement", comment: "User Agreement")
        default:
            cell.textLabel!.text = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "aboutSegue", sender: nil)
        case 1:
            performSegue(withIdentifier: "contactSegue", sender: nil)
        case 2:
            sendFeedback()
        case 3:
            performSegue(withIdentifier: "agreementSegue", sender: nil)
        default:
            performSegue(withIdentifier: "privacySegue", sender: nil)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("Feedback")
            controller.setToRecipients(["tjson@newtortoise.com"])
            controller.setMessageBody("Hello!", isHTML: false)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
